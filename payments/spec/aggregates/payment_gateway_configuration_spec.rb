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

    specify 'cannot register already registered payment gateway' do
      payment_gateway_configuration = PaymentGatewayConfiguration.new
      payment_gateway_configuration.register(payment_gateway_identifier, adapter, fallback_identifier)

      expect do
        payment_gateway_configuration.register(payment_gateway_identifier, adapter, fallback_identifier)
      end.to raise_error(PaymentGatewayConfiguration::InvalidOperation)
    end

    specify 'choose primary gateway' do
      payment_gateway_configuration = PaymentGatewayConfiguration.new
      payment_gateway_configuration.register(payment_gateway_identifier, adapter, fallback_identifier)
      payment_gateway_configuration.choose_primary(payment_gateway_identifier)

      expect(payment_gateway_configuration).to(have_applied(primary_payment_gateway_chosen))
    end

    specify 'switch to fallback gateway' do
      payment_gateway_configuration = PaymentGatewayConfiguration.new
      payment_gateway_configuration.register(payment_gateway_identifier, adapter, fallback_identifier)
      payment_gateway_configuration.switch_to_fallback(payment_gateway_identifier)

      expect(payment_gateway_configuration).to(have_applied(payment_gateway_swtiched_to_fallback))
    end

    specify 'there is no fallback gateway to switch' do
      payment_gateway_configuration = PaymentGatewayConfiguration.new
      payment_gateway_configuration.register(payment_gateway_identifier, adapter, nil)

      expect do
        payment_gateway_configuration.switch_to_fallback(payment_gateway_identifier)
      end.to raise_error(PaymentGatewayConfiguration::InvalidOperation)
    end

    private

    def payment_gateway_registered
      an_event(Payments::PaymentGatewayRegistered).with_data(payment_gateway_registered_data).strict
    end

    def primary_payment_gateway_chosen
      an_event(Payments::PrimaryPaymentGatewayChosen).with_data(primary_payment_gateway_chosen_data).strict
    end

    def payment_gateway_swtiched_to_fallback
      an_event(Payments::PaymentGatewaySwitchedToFallback).with_data(payment_gateway_swtiched_to_fallback_data).strict
    end

    def payment_gateway_registered_data
      {
        payment_gateway_identifier: payment_gateway_identifier,
        adapter:                    adapter,
        fallback_identifier:        fallback_identifier
      }
    end

    def primary_payment_gateway_chosen_data
      {
        payment_gateway_identifier: payment_gateway_identifier
      }
    end

    def payment_gateway_swtiched_to_fallback_data
      {
        payment_gateway_identifier: payment_gateway_identifier
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
