module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    def initialize(transaction_identifier, payment_gateway:)
      @transaction_identifier                 = transaction_identifier
      @payment_gateway_transaction_identifier = nil
      @payment_gateway                        = payment_gateway
      @state                                  = :unauthorized
    end

    def authorize(credit_card_token, amount, currency, order_number)
      raise InvalidOperation if authorized?

      payment_gateway_transaction_identifier = @payment_gateway.authorize(credit_card_token, amount, currency)

      # NOTE: Should I include amount and currency here?
      apply(Payments::CreditCardAuthorizationSucceeded.strict(data: {
        transaction_identifier:                 @transaction_identifier,
        payment_gateway_transaction_identifier: payment_gateway_transaction_identifier,
        order_number:                           order_number,
        amount:                                 amount,
        currency:                               currency
      }))
    rescue Payments::AuthorizationFailed
      apply(Payments::CreditCardAuthorizationFailed.strict(data: {
        transaction_identifier: @transaction_identifier,
        order_number:           order_number
      }))
    end

    private

    def authorized?
      @state == :authorized
    end

    def apply_credit_card_authorization_succeeded(event)
      @transaction_identifier                 = event.data[:transaction_identifier]
      @payment_gateway_transaction_identifier = event.data[:payment_gateway_transaction_identifier]
      @state                                  = :authorized
    end

    def apply_credit_card_authorization_failed(event)
    end
  end
end
