module Payments
  class CaptureFailed < RailsEventStore::Event
    SCHEMA = {
      transaction_identifier: String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
