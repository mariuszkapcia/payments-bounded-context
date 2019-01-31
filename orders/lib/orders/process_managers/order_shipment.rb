module Orders
  class OrderShipment
    class State
      attr_reader :order_uuid

      def initialize
        @order_state    = :draft
        @payment_state  = :none
        @order_uuid     = nil

        @version           = -1
        @event_ids_to_link = []
      end

      def ship?
        @order_state == :submitted && @payment_state == :authorized
      end

      def apply_order_submitted(event)
        @order_state = :submitted
        @order_uuid  = event.data[:order_uuid]
      end

      def apply_order_cancelled
        @order_state = :cancelled
      end

      def apply_order_shipped
        @order_state = :shipped
      end

      def apply_authorization_succeeded(event)
        @payment_state = :authorized
      end

      def apply_authorization_failed
        @payment_state = :authorization_failed
      end

      # NOTE: In the more complex system, we would handle more events here, for example from Inventory bounded context.
      def apply(*events)
        events.each do |event|
          case event
          when Orders::OrderSubmitted           then apply_order_submitted(event)
          when Payments::AuthorizationSucceeded then apply_authorization_succeeded(event)
          when Payments::AuthorizationFailed    then apply_authorization_failed
          when Orders::OrderCancelled           then apply_order_cancelled
          when Orders::OrderShipped             then apply_order_shipped
          end

          @event_ids_to_link << event.event_id
        end
      end

      def load(stream_name, event_store:)
        event_store.read.stream(stream_name).forward.each do |event|
          apply(event)
          @version += 1
        end

        @event_ids_to_link = []
      end

      def store(stream_name, event_store:)
        event_store.link(
          @event_ids_to_link,
          stream_name:      stream_name,
          expected_version: @version
        )

        @version          += @event_ids_to_link.size
        @event_ids_to_link = []
      rescue RubyEventStore::WrongExpectedVersion
        retry
      end
    end
    private_constant :State

    def call(event)
      stream_name = "OrderShipment$#{event.data[:order_number]}"

      state = State.new
      state.load(stream_name, event_store: @event_store)
      state.apply(event)
      state.store(stream_name, event_store: @event_store)

      if state.ship?
        @command_bus.call(Orders::ShipOrder.new(order_uuid: state.order_uuid))
      end
    end

    private

    def initialize(event_store:, command_bus:)
      @event_store = event_store
      @command_bus = command_bus
    end
  end
end
