module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(transaction_identifier, payment_gateway:)
      @transaction_identifier                 = transaction_identifier
      @payment_gateway_transaction_identifier = nil
      @payment_gateway                        = payment_gateway
      @order_number                           = nil
      @state                                  = :none
    end

    def authorize(credit_card_token, amount, currency, order_number)
      raise InvalidOperation if authorized?

      payment_gateway_transaction_identifier = @payment_gateway.authorize(credit_card_token, amount, currency)

      apply(Payments::AuthorizationSucceeded.strict(data: {
        transaction_identifier:                 @transaction_identifier,
        payment_gateway_transaction_identifier: payment_gateway_transaction_identifier,
        payment_gateway_identifier:             @payment_gateway.identifier,
        order_number:                           order_number
      }))
    rescue VisaPaymentGateway::AuthorizationFailed,
           MastercardPaymentGateway::AuthorizationFailed
      apply(Payments::AuthorizationFailed.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: @payment_gateway.identifier,
        order_number:               order_number
      }))
    end

    def capture
      raise InvalidOperation unless authorized?
      raise InvalidOperation if captured?

      @payment_gateway.capture(@payment_gateway_transaction_identifier)

      apply(Payments::CaptureSucceeded.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: @payment_gateway.identifier,
        order_number:               order_number
      }))
    rescue VisaPaymentGateway::CaptureFailed,
           MastercardPaymentGateway::CaptureFailed
      apply(Payments::CaptureFailed.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: @payment_gateway.identifier,
        order_number:               order_number
      }))
    end

    def void
      raise InvalidOperation unless authorized?
      raise InvalidOperation if voided?

      @payment_gateway.void(@payment_gateway_transaction_identifier)

      apply(Payments::VoidSucceeded.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: @payment_gateway.identifier,
        order_number:               order_number
      }))
    rescue VisaPaymentGateway::VoidFailed,
           MastercardPaymentGateway::VoidFailed
      apply(Payments::VoidFailed.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: @payment_gateway.identifier,
        order_number:               order_number
      }))
    end

    private

    def authorized?
      @state == :authorized
    end

    def captured?
      @state == :captured
    end

    def voided?
      @state == :voided
    end

    def apply_authorization_succeeded(event)
      @transaction_identifier                 = event.data[:transaction_identifier]
      @payment_gateway_transaction_identifier = event.data[:payment_gateway_transaction_identifier]
      @order_number                           = event.data[:order_number]
      @state                                  = :authorized
    end

    def apply_authorization_failed(event)
    end

    def apply_capture_succeeded(event)
      @state = :captured
    end

    def apply_capture_failed(event)
    end

    def apply_void_succeeded(event)
      @state = :voided
    end

    def apply_void_failed(event)
    end
  end
end
