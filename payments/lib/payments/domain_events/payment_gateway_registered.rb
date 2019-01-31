module Payments
  class PaymentGatewayRegistered < RailsEventStore::Event
    SCHEMA = {
      payment_gateway_identifier: String,
      adater:                     String,
      fallback_adapter:           String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
