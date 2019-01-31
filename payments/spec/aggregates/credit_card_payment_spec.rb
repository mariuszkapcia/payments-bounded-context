require_dependency 'payments'

module Payments
  class FakePaymentGateway
    def authorize(credit_card_token, amount, currency)
      raise PaymentGatewayAuthorizationFailed if @broken
      'payment_gateway_transaction_identifier'
    end

    def capture(transaction_identifier)
      raise PaymentGatewayCaptureFailed if @broken
      true
    end

    def void(transaction_identifier)
      raise PaymentGatewayVoidFailed if @broken
      true
    end

    def identifier
      'fake'
    end

    def break
      @broken = true
    end

    private

    def initialize(broken:)
      @broken = broken
    end
  end

  RSpec.describe 'CreditCardPayment aggregate' do
    specify 'authorize payment' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)

      expect(credit_card_payment).to(have_applied(authorization_succeeded))
    end

    specify 'payment authorization failed' do
      payment_gateway     = fake_payment_gateway(broken: true)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)

      expect(credit_card_payment).to(have_applied(authorization_failed))
    end

    specify 'cannot authorize already authorized payment' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)

      expect do
        credit_card_payment.authorize(credit_card_token, amount, currency, order_number)
      end.to raise_error(CreditCardPayment::InvalidOperation)
    end

    specify 'caputre authorization' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)
      credit_card_payment.capture

      expect(credit_card_payment).to(have_applied(capture_succeeded))
    end

    specify 'authorization capture failed' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)
      payment_gateway.break
      credit_card_payment.capture

      expect(credit_card_payment).to(have_applied(capture_failed))
    end

    specify 'cannot capture not authorized payment' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)

      expect do
        credit_card_payment.capture
      end.to raise_error(CreditCardPayment::InvalidOperation)
    end

    specify 'cannot capture already captured authorization payment' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)
      credit_card_payment.capture

      expect do
        credit_card_payment.capture
      end.to raise_error(CreditCardPayment::InvalidOperation)
    end

    specify 'void authorization' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)
      credit_card_payment.void

      expect(credit_card_payment).to(have_applied(void_succeeded))
    end

    specify 'authorization void failed' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)
      payment_gateway.break
      credit_card_payment.void

      expect(credit_card_payment).to(have_applied(void_failed))
    end

    specify 'cannot void not authorized payment' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)

      expect do
        credit_card_payment.void
      end.to raise_error(CreditCardPayment::InvalidOperation)
    end

    specify 'cannot void already voided authorization payment' do
      payment_gateway     = fake_payment_gateway(broken: false)
      credit_card_payment = CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway)
      credit_card_payment.authorize(credit_card_token, amount, currency, order_number)
      credit_card_payment.void

      expect do
        credit_card_payment.void
      end.to raise_error(CreditCardPayment::InvalidOperation)
    end

    private

    def authorization_succeeded
      an_event(Payments::AuthorizationSucceeded).with_data(authorization_succeeded_data).strict
    end

    def authorization_failed
      an_event(Payments::AuthorizationFailed).with_data(authorization_failed_data).strict
    end

    def capture_succeeded
      an_event(Payments::CaptureSucceeded).with_data(capture_succeeded_data).strict
    end

    def capture_failed
      an_event(Payments::CaptureFailed).with_data(capture_failed_data).strict
    end

    def void_succeeded
      an_event(Payments::VoidSucceeded).with_data(void_succeeded_data).strict
    end

    def void_failed
      an_event(Payments::VoidFailed).with_data(void_failed_data).strict
    end

    def authorization_succeeded_data
      {
        transaction_identifier:                 transaction_identifier,
        payment_gateway_transaction_identifier: kind_of(String),
        payment_gateway_identifier:             fake_payment_gateway.identifier,
        order_number:                           order_number
      }
    end

    def authorization_failed_data
      {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: fake_payment_gateway.identifier,
        order_number:               order_number
      }
    end

    def capture_succeeded_data
      {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: fake_payment_gateway.identifier,
        order_number:               order_number
      }
    end

    def capture_failed_data
      {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: fake_payment_gateway.identifier,
        order_number:               order_number
      }
    end

    def void_succeeded_data
      {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: fake_payment_gateway.identifier,
        order_number:               order_number
      }
    end

    def void_failed_data
      {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: fake_payment_gateway.identifier,
        order_number:               order_number
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

    def fake_payment_gateway(broken: false)
      FakePaymentGateway.new(broken: broken)
    end
  end
end
