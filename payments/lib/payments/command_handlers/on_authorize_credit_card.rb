module Payments
  class OnAuthorizeCreditCard
    def call(command)
      command.verify!

      ActiveRecord::Base.transaction do
        with_payment(command.transaction_identifier, payment_gateway: @payment_gateway) do |payment|
          payment.authorize(command.credit_card_token, command.amount, command.currency, command.order_number)
        end
      end
    end

    private

    def initialize(event_store, payment_gateway: Payments::VisaPaymentGateway.new)
      @event_store     = event_store
      @payment_gateway = payment_gateway
    end

    def with_payment(transaction_identifier, payment_gateway:)
      Payments::CreditCardPayment.new(transaction_identifier, payment_gateway: payment_gateway).tap do |payment|
        load_payment(transaction_identifier, payment)
        yield payment
        store_payment(payment)
      end
    end

    def load_payment(transaction_identifier, payment)
      payment.load(stream_name(transaction_identifier), event_store: @event_store)
    end

    def store_payment(payment)
      payment.store(event_store: @event_store)
    end

    def stream_name(transaction_identifier)
      "Payments::CreditCardPayment$#{transaction_identifier}"
    end
  end
end
