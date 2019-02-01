require_dependency 'payments'

require_relative '../support/fakes'

module Payments
  RSpec.describe 'PaymentGatewayConfiguration aggregate' do
    include Fakes

    specify 'register payment gateway' do
      payment_gateway_configuration = PaymentGatewayConfiguration.new
      payment_gateway_configuration.register(payment_gateway_identifier, adapter, fallback_identifier)

      expect(payment_gateway_configuration).to(have_applied(payment_gateway_registered))
    end

    private

    def payment_gateway_registered
      an_event(Payments::PaymentGatewayRegistered).with_data(payment_gateway_registered_data).strict
    end

    def payment_gateway_registered_data
      {
        payment_gateway_identifier: payment_gateway_identifier,
        adapter:                    adapter,
        fallback_identifier:        fallback_identifier
      }
    end

    def payment_gateway_identifier
      'payment_gateway_identifier'
    end

    def adapter
      'adapter'
    end

    def fallback_identifier
      'fallback_identifier'
    end
  end
end
