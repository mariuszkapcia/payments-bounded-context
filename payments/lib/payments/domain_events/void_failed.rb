module Payments
  class VoidFailed < RailsEventStore::Event
    SCHEMA = {
      transaction_identifier:     String,
      payment_gateway_identifier: String,
      order_number:               String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
