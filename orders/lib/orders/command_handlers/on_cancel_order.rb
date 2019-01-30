module Orders
  class OnCancelOrder
    def call(command)
      command.verify!

      ActiveRecord::Base.transaction do
        order = Order.new(command.order_uuid)
        order.load(stream_name(command.order_uuid), event_store: @event_store)
        order.cancel
        order.store(event_store: @event_store)
      end
    end

    private

    def initialize(event_store)
      @event_store = event_store
    end

    def stream_name(order_uuid)
      "Orders$Order#{order_uuid}"
    end
  end
end
