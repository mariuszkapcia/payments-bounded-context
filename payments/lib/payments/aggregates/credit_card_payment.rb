module Payments
  class CreditCardPayment
    include AggregateRoot

    def initialize(transaction_identifier, payment_gateway:)
      @transaction_identifier = transaction_identifier
      @payment_gateway        = payment_gateway
    end

    def authorize(credit_card_token, amount, currency, order_number)
      transaction_identifier = @payment_gateway.authorize(credit_card_token, amount, currency)

      # NOTE: Should I include amount and currency here?
      apply(Payments::CreditCardAuthorizationSucceeded.strict(data: {
        transaction_identifier: transaction_identifier,
        order_number:           order_number,
        amount:                 amount,
        currency:               currency
      }))
    rescue Payments::AuthorizationFailed
      apply(Payments::CreditCardAuthorizationFailed.strict(data: {
        order_number: order_number
      }))
    end

    private

    def apply_credit_card_authorization_succeeded(event)
      @state = :authorized
    end
  end
end
