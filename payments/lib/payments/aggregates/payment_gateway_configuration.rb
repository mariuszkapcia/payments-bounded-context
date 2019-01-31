module Payments
  class PaymentGatewayConfiguration
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize
      @payment_gateways = []
    end

    def register(payment_gateway_identifier, adapter, fallback_identifier)
      raise InvalidOperation if gateway_already_registered?(payment_gateway_identifier)

      apply(Payments::PaymentGatewayRegistered.strict(data: {
        payment_gateway_identifier: payment_gateway_identifier,
        adater:                     adapter,
        fallback_identifier:        fallback_identifier
      }))
    end

    def choose_primary(payment_gateway_identifier)
      apply(Payments::PrimaryPaymentGatewayChosen.strict(data: {
        payment_gateway_identifier: payment_gateway_identifier
      }))
    end

    def switch_to_fallback(payment_gateway_identifier)
      apply(Payments::PaymentGatewaySwitchedToFallback.strict(data: {
        payment_gateway_identifier: payment_gateway_identifier
      }))
    end

    private

    def gateway_already_registered?(identifier)
      @payment_gateways.any? { |gateway| gateway[:identifier] == identifier }
    end

    def apply_payment_gateway_registered(event)
      @payment_gateways << {
        identifier: event.data[:payment_gateway_identifier]
      }
    end

    def apply_primary_payment_gateway_chosen(event)
    end

    def apply_payment_gateway_switched_to_fallback(event)
    end
  end
end
