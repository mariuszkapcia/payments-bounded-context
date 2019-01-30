module Orders
  class Order
    include AggregateRoot

    NotAllowed = Class.new(StandardError)

    def initailize(uuid)
      @state  = :draft
      @uuid   = uuid
      @number = nil
    end

    def submit(order_number)
      raise NotAllowed unless draft?

      apply(Orders::OrderSubmitted.strict(data: {
        order_uuid:   @uuid,
        order_number: order_number
      }))
    end

    def cancel
      raise NotAllowed unless draft? || submitted?

      apply(Orders::OrderCancelled.strict(data: {
        order_uuid:   @uuid,
        order_number: @number
      }))
    end

    def ship
      raise NotAllowed unless submitted?
      raise NotAllowed if shipped?

      apply(Orders::OrderShipped.strict(data: {
        order_uuid:   @uuid,
        order_number: @number
      }))
    end

    private

    def draft?
      @state == :draft
    end

    def submitted?
      @state == :submitted
    end

    def cancelled?
      @state == :cancelled
    end

    def shipped?
      @state == :shipped
    end

    def apply_order_submitted(event)
      @state  = :submitted
      @number = event.data[:order_number]
    end

    def apply_order_cancelled(event)
      @state = :cancelled
    end

    def apply_order_shipped(event)
      @state = :shipped
    end
  end
end
