module Orders
  class OnSubmitOrder
    def call(command)
      command.verify!

      ActiveRecord::Base.transaction do
        order = Order.new(command.order_uuid)
        order.load(stream_name(command.order_uuid), event_store: @event_store)
        order_number = @order_number_generator.call
        order.submit(order_number)
        order.store(event_store: @event_store)
      end
    end

    private

    def initialize(event_store, order_number_generator: OrderNumberGenerator.new)
      @event_store            = event_store
      @order_number_generator = order_number_generator
    end

    def stream_name(order_uuid)
      "Orders$Order#{order_uuid}"
    end
  end
end
