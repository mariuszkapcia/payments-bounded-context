module Orders
  class OrderFulfillment
    class State
      attr_reader :transaction_identifier

      def initialize
        @order_state            = :draft
        @payment_state          = :none
        @transaction_identifier = nil

        @version           = -1
        @event_ids_to_link = []
      end

      def capture?
        @order_state == :shipped && @payment_state.in?([:authorized, :capture_failed])
      end

      def void?
        @order_state == :cancelled && @payment_state.in?([:authorized, :void_failed])
      end

      def apply_order_submitted
        @order_state  = :submitted
      end

      def apply_order_cancelled
        @order_state = :cancelled
      end

      def apply_order_shipped
        @order_state = :shipped
      end

      def apply_authorization_succeeded(event)
        @payment_state          = :authorized
        @transaction_identifier = event.data[:transaction_identifier]
      end

      def apply_authorization_failed
        @payment_state = :authorization_failed
      end

      def apply_capture_succeeded
        @payment_state = :captured
      end

      def apply_capture_failed
        @payment_state = :capture_failed
      end

      def apply_void_succeeded
        @payment_state = :voided
      end

      def apply_void_failed
        @payment_state = :void_failed
      end

      def apply(*events)
        events.each do |event|
          case event
          when Orders::OrderSubmitted           then apply_order_submitted
          when Payments::AuthorizationSucceeded then apply_authorization_succeeded(event)
          when Payments::AuthorizationFailed    then apply_authorization_failed
          when Orders::OrderCancelled           then apply_order_cancelled
          when Orders::OrderShipped             then apply_order_shipped
          when Payments::CaptureSucceeded       then apply_capture_succeeded
          when Payments::CaptureFailed          then apply_capture_failed
          when Payments::VoidSucceeded          then apply_void_succeeded
          when Payments::VoidFailed             then apply_void_failed
          end

          @event_ids_to_link << event.event_id
        end
      end

      def load(stream_name, event_store:)
        events = event_store.read.stream(stream_name).forward.each
        events.each do |event|
          apply(event)
        end

        @version           = events.size - 1
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
      stream_name = "OrderFulfillment$#{event.data[:order_number]}"

      state = State.new
      state.load(stream_name, event_store: @event_store)
      state.apply(event)
      state.store(stream_name, event_store: @event_store)

      if state.capture?
        @command_bus.call(Payments::CaptureAuthorization.new(transaction_identifier: state.transaction_identifier))
      end

      if state.void?
        @command_bus.call(Payments::VoidAuthorization.new(transaction_identifier: state.transaction_identifier))
      end
    end

    private

    def initialize(event_store:, command_bus:)
      @event_store = event_store
      @command_bus = command_bus
    end
  end
end
