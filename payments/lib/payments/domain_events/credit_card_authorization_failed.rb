module Payments
  class CreditCardAuthorizationFailed < RailsEventStore::Event
    SCHEMA = {
      order_number: String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
