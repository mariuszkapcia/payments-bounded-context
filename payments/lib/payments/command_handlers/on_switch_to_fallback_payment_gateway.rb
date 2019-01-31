module Payments
  class OnSwitchToFallbackPaymentGateway
    def call(command)
      command.verify!

      ActiveRecord::Base.transaction do
        payment_gateway_configuration = PaymentGatewayConfiguration.new
        payment_gateway_configuration.load(stream_name, event_store: @event_store)
        payment_gateway_configuration.switch_to_fallback(command.payment_gateway_identifier)
        payment_gateway_configuration.store(event_store: @event_store)
      end
    end

    private

    def initialize(event_store)
      @event_store = event_store
    end

    def stream_name
      'Payments::PaymentGatewayConfiguration'
    end
  end
end