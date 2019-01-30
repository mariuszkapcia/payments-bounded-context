module Payments
  class CreditCardAuthorizationSucceeded < RailsEventStore::Event
    SCHEMA = {
      transaction_identifier: String,
      order_number:           String,
      amount:                 Integer,
      currency:               String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
