module Orders
  class Order
    include AggregateRoot

    NotAllowed = Class.new(StandardError)

    def initailize(uuid)
      @state  = :draft
      @uuid   = uuid
    end

    def submit(order_number)
      raise NotAllowed unless draft?

      apply(Orders::OrderSubmitted.strict(data: {
        order_uuid:   @uuid,
        order_number: order_number
      }))
    end

    def ship
      raise NotAllowed unless submitted?
      raise NotAllowed if shipped?

      apply(Orders::OrderShipped.strict(data: {
        order_uuid: @uuid
      }))
    end

    private

    def draft?
      @state == :draft
    end

    def submitted?
      @state == :submitted
    end

    def shipped?
      @state == :shipped
    end

    def apply_order_submitted(event)
      @state = :submitted
    end

    def apply_order_shipped(event)
      @state = :shipped
    end
  end
end
