module Payments
  class PaymentGatewayRegistered < RailsEventStore::Event
    SCHEMA = {
      payment_gateway_identifier: String,
      adapter:                    String,
      fallback_identifier:        [String, NilClass]
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
