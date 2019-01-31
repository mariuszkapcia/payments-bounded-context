require_dependency 'payments'

module Payments
  class FakePaymentGateway
    def authorize(credit_card_token, amount, currency)
      'payment_gateway_transaction_identifier'
    end

    def capture(transaction_identifier)
      true
    end

    def void(transaction_identifier)
      true
    end

    def identifier
      'fake'
    end
  end

  RSpec.describe 'CreditCardPayment aggregate' do
    specify 'authorize payment' do
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: fake_payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)

      expect(credit_card_payment).to(have_applied(authorization_succeeded))
    end

    private

    def authorization_succeeded
      an_event(Payments::AuthorizationSucceeded).with_data(authorization_succeeded_data).strict
    end

    def authorization_succeeded_data
      {
        transaction_identifier:                 transaction_identifier,
        payment_gateway_transaction_identifier: kind_of(String),
        payment_gateway_identifier:             fake_payment_gateway.identifier,
        order_number:                           order_number
      }
    end

    def transaction_identifier
      'transaction_identifier'
    end

    def credit_card_token
      'credit_card_token'
    end

    def amount
      0
    end

    def currency
      'USD'
    end

    def order_number
      'order_number'
    end

    def fake_payment_gateway
      @fake_payment_gateway ||= FakePaymentGateway.new
    end
  end
end
