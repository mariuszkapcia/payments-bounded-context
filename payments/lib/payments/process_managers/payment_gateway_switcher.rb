module Payments
  class PaymentGatewaySwitcher
    # NOTE: State should be stored as database table because of number of events in the stream.
    #       This is simplified implementation.
    class State
      def initialize
        @payment_gateways  = {}
        @version           = -1
        @event_ids_to_link = []
      end

      def prepare_state(payment_gateway_identifier)
        @payment_gateways[payment_gateway_identifier] ||= {}
        @payment_gateways[payment_gateway_identifier]['failed_payments_count'] ||= 0
      end

      def purge(payment_gateway_identifier)
        @payment_gateways[payment_gateway_identifier]['failed_payments_count'] = 0
      end

      def increment_counter(payment_gateway_identifier)
        @payment_gateways[payment_gateway_identifier]['failed_payments_count'] += 1
      end

      def failures_count(payment_gateway_identifier)
        @payment_gateways[payment_gateway_identifier]['failed_payments_count']
      end

      def apply(*events)
        prepare_state(events.first.data[:payment_gateway_identifier])

        events.each do |event|
          case event
          when Payments::AuthorizationSucceeded,
               Payments::CaptureSucceeded,
               Payments::VoidSucceeded
            purge(event.data[:payment_gateway_identifier])
          when Payments::AuthorizationFailed,
               Payments::CaptureFailed,
               Payments::VoidFailed
            increment_counter(event.data[:payment_gateway_identifier])
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
      stream_name = 'PaymentGatewaySwitcher'

      state = State.new
      state.load(stream_name, event_store: @event_store)
      state.apply(event)
      state.store(stream_name, event_store: @event_store)

      failures_count = state.failures_count(event.data[:payment_gateway_identifier])
      if failures_count > @fallback_configuration.max_failed_payments_count
        @command_bus.call(
          Payments::SwitchToFallbackPaymentGateway.new(
            payment_gateway_identifier: event.data[:payment_gateway_identifier]
          )
        )

        state.purge(event.data[:payment_gateway_identifier])
      end
    end

    private

    def initialize(event_store:, command_bus:, fallback_configuration:)
      @event_store            = event_store
      @command_bus            = command_bus
      @fallback_configuration = fallback_configuration
    end
  end
end
