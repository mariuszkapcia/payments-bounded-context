module Payments
  # NOTE: We need to decide what to use as aggregate identifier here (part of the stream name).
  #       I can see two possible options:
  #       1) We can add internal transaction identifier to the command and in addition keep payment gateway
  #          transaction identifier as part of the aggregate state. In this case, we can call payment gateway inside
  #          aggregate.
  #       2) We can have only payment gateway transaction identifier but in this case, we need to call payment gateway
  #          from command handler because we need transaction identifier to store aggregate.
  class OnAuthorizeCreditCard
    def call(command)
      command.verify!

      ActiveRecord::Base.transaction do
        credit_card_payment = CreditCardPayment.new(
          command.transaction_identifier,
          payment_gateway_list: @payment_gateway_list
        )
        credit_card_payment.load(stream_name(command.transaction_identifier), event_store: @event_store)
        credit_card_payment.authorize(command.credit_card_token, command.amount, command.currency, command.order_number)
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
