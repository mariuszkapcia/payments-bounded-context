module Orders
  class OrderShipped < RailsEventStore::Event
    SCHEMA = {
      order_uuid: String
    }.freeze

    def self.strict(data:)
      ClassyHash.validate(data, SCHEMA)
      new(data: data)
    end
  end
end
