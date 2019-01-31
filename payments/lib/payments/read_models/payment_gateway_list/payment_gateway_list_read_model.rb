module Payments
  class PaymentGatewayListReadModel
    def call(event)
      case event
      when Payments::PaymentGatewayRegistered
        add_payment_gateway(
          event.data[:payment_gateway_identifier],
          event.data[:adater],
          event.data[:fallback_identifier]
        )
      when Payments::PrimaryPaymentGatewayChosen
        choose_primary(event.data[:payment_gateway_identifier])
      when Payments::PaymentGatewaySwitchedToFallback
        switch_to_fallback(event.data[:payment_gateway_identifier])
      end
    end

    def fetch_primary
      payment_gateway = Payments::PaymentGatewayList::PaymentGateway.where(primary: true).take
      payment_gateway.adater.constantize.new
    end

    def find(identifier)
      payment_gateway = Payments::PaymentGatewayList::PaymentGateway.find_by(identifier: identifier)
      payment_gateway.adater.constantize.new
    end

    private

    def add_payment_gateway(payment_gateway_identifier, adater, fallback_identifier)
      Payments::PaymentGatewayList::PaymentGateway.create!(
        identifier:          payment_gateway_identifier,
        adater:              adater,
        fallback_identifier: fallback_identifier,
        primary:             false
      )
    end

    def choose_primary(payment_gateway_identifier)
      payment_gateway = Payments::PaymentGatewayList::PaymentGateway.find_by(identifier: payment_gateway_identifier)
      payment_gateway.primary = true
      payment_gateway.save!
    end

    def switch_to_fallback(payment_gateway_identifier)
      payment_gateway = Payments::PaymentGatewayList::PaymentGateway.find_by(identifier: payment_gateway_identifier)
      payment_gateway.primary = false
      payment_gateway.save!

      fallback = Payments::PaymentGatewayList::PaymentGateway.find_by(identifier: payment_gateway.fallback_identifier)
      fallback.primary = true
      fallback.save!
    end
  end
end
