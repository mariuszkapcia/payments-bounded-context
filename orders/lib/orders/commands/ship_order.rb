module Orders
  class ShipOrder
    include Command

    attr_accessor :order_uuid

    def initialize(order_uuid:)
      @order_uuid = order_uuid
    end
  end
end
