module Payments
  class PaymentGatewaySwitchedToFallback < RailsEventStore::Event
    SCHEMA = {
      payment_gateway_identifier: String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
