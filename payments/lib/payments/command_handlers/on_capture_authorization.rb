module Payments
  class OnCaptureAuthorization
    def call(command)
      command.verify!

      ActiveRecord::Base.transaction do
        credit_card_payment = CreditCardPayment.new(command.transaction_identifier, payment_gateway: @payment_gateway)
        credit_card_payment.load(stream_name(command.transaction_identifier), event_store: @event_store)
        credit_card_payment.capture
        credit_card_payment.store(event_store: @event_store)
      end
    end

    private

    def initialize(event_store, payment_gateway: VisaPaymentGateway.new)
      @event_store     = event_store
      @payment_gateway = payment_gateway
    end

    def stream_name(transaction_identifier)
      "Payments::CreditCardPayment$#{transaction_identifier}"
    end
  end
end
