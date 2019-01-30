module Payments
  class AuthorizationFailed < RailsEventStore::Event
    SCHEMA = {
      transaction_identifier: String,
      order_number:           String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end