module Payments
  class OnVoidAuthorization
    def call(command)
      command.verify!

      ActiveRecord::Base.transaction do
        credit_card_payment = CreditCardPayment.new(
          command.transaction_identifier,
          payment_gateway_list: @payment_gateway_list
        )
        credit_card_payment.load(stream_name(command.transaction_identifier), event_store: @event_store)
        credit_card_payment.void
        credit_card_payment.store(event_store: @event_store)
      end
    end

    private

    def initialize(event_store, payment_gateway_list: PaymentGatewayListReadModel.new)
      @event_store          = event_store
      @payment_gateway_list = payment_gateway_list
    end

    def stream_name(transaction_identifier)
      "Payments::CreditCardPayment$#{transaction_identifier}"
    end
  end
end
