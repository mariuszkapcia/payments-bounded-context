require_dependency 'payments'

module Payments
  RSpec.describe 'PaymentGatewayList read model' do
    specify 'normal flow of events' do
      read_model.call(visa_payment_gateway_registered)
      read_model.call(mastercard_payment_gateway_registered)
      read_model.call(primary_payment_gateway_chosen)
      assert_payment_gateway_correct

      read_model.call(payment_gateway_switched_to_fallback)
      assert_fallback_payment_gateway_correct
    end

    private

    def assert_payment_gateway_correct
      payment_gateway = payment_gateway(payment_gateway_identifier)
      expect(payment_gateway).to be_instance_of(VisaPaymentGateway)
      expect(primary_payment_gateway).to be_instance_of(VisaPaymentGateway)
    end

    def assert_fallback_payment_gateway_correct
      expect(primary_payment_gateway).to be_instance_of(MastercardPaymentGateway)
    end

    def visa_payment_gateway_registered
      Payments::PaymentGatewayRegistered.new(data: {
        payment_gateway_identifier: payment_gateway_identifier,
        adapter:                    adapter,
        fallback_identifier:        fallback_identifier
      })
    end

    def mastercard_payment_gateway_registered
      Payments::PaymentGatewayRegistered.new(data: {
        payment_gateway_identifier: 'mastercard',
        adapter:                    'Payments::MastercardPaymentGateway',
        fallback_identifier:        nil
      })
    end

    def primary_payment_gateway_chosen
      Payments::PrimaryPaymentGatewayChosen.new(data: {
        payment_gateway_identifier: payment_gateway_identifier
      })
    end

    def payment_gateway_switched_to_fallback
      Payments::PaymentGatewaySwitchedToFallback.new(data: {
        payment_gateway_identifier: payment_gateway_identifier
      })
    end

    def payment_gateway_identifier
      'visa'
    end

    def adapter
      'Payments::VisaPaymentGateway'
    end

    def fallback_identifier
      'mastercard'
    end

    def read_model
      @payment_gateway_list_read_model ||= PaymentGatewayListReadModel.new
    end

    def primary_payment_gateway
      read_model.fetch_primary
    end

    def payment_gateway(identifier)
      read_model.find(identifier)
    end
  end
end
