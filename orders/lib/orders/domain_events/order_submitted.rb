module Orders
  class OrderSubmitted < RailsEventStore::Event
    SCHEMA = {
      order_uuid:   String,
      order_number: String,
      gross_value:  Integer,
      currency:     String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
