module Orders
  class Order
    include AggregateRoot

    def initailize(uuid)
      @state  = :draft
      @uuid   = uuid
    end

    def submit(order_number)
      apply(Orders::OrderSubmitted.strict(data: {
        order_uuid:   @uuid,
        order_number: order_number
      }))
    end

    def ship
      apply(Orders::OrderShipped.strict(data: {
        order_uuid: @uuid
      }))
    end

    private

    def apply_order_submitted(event)
      @state = :submitted
    end

    def apply_order_shipped(event)
      @state = :shipped
    end
  end
end
