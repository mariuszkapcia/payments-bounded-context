module Payments
  class AuthorizationSucceeded < RailsEventStore::Event
    SCHEMA = {
      transaction_identifier:                 String,
      payment_gateway_transaction_identifier: String,
      payment_gateway_identifier:             String,
      order_number:                           String,
      amount:                                 Integer,
      currency:                               String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
