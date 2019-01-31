require_dependency 'orders'

module Orders
  RSpec.describe 'Order aggregate' do
    specify 'submit order' do
      order = Order.new(order_uuid)
      order.submit(order_number)

      expect(order).to(have_applied(order_submitted))
    end

    specify 'cannot submit already submitted order' do
      order = Order.new(order_uuid)
      order.submit(order_number)

      expect do
        order.submit(order_number)
      end.to raise_error(Order::NotAllowed)
    end

    specify 'cannot submit shipped order' do
      order = Order.new(order_uuid)
      order.submit(order_number)
      order.ship

      expect do
        order.submit(order_number)
      end.to raise_error(Order::NotAllowed)
    end

    specify 'cannot submit cancelled order' do
      order = Order.new(order_uuid)
      order.submit(order_number)
      order.cancel

      expect do
        order.submit(order_number)
      end.to raise_error(Order::NotAllowed)
    end

    specify 'ship order' do
      order = Order.new(order_uuid)
      order.submit(order_number)
      order.ship

      expect(order).to(have_applied(order_shipped))
    end

    specify 'cannot ship not submitted order' do
      order = Order.new(order_uuid)

      expect do
        order.ship
      end.to raise_error(Order::NotAllowed)
    end

    specify 'cannot ship already shipped order' do
      order = Order.new(order_uuid)

      expect do
        order.ship
      end.to raise_error(Order::NotAllowed)
    end

    specify 'cancel order' do
      order = Order.new(order_uuid)
      order.submit(order_number)
      order.cancel

      expect(order).to(have_applied(order_cancelled))
    end

    specify 'cannot cancel not submitted order' do
      order = Order.new(order_uuid)

      expect do
        order.cancel
      end.to raise_error(Order::NotAllowed)
    end

    specify 'cannot cancel already cancelled order' do
      order = Order.new(order_uuid)
      order.submit(order_number)
      order.cancel

      expect do
        order.cancel
      end.to raise_error(Order::NotAllowed)
    end

    private

    def order_submitted
      an_event(Orders::OrderSubmitted).with_data(order_submitted_data).strict
    end

    def order_shipped
      an_event(Orders::OrderShipped).with_data(order_shipped_data).strict
    end

    def order_cancelled
      an_event(Orders::OrderCancelled).with_data(order_cancelled_data).strict
    end

    def order_submitted_data
      {
        order_uuid:   order_uuid,
        order_number: order_number,
        gross_value:  0,
        currency:     'USD'
      }
    end

    def order_shipped_data
      {
        order_uuid:   order_uuid,
        order_number: order_number
      }
    end

    def order_cancelled_data
      {
        order_uuid:   order_uuid,
        order_number: order_number
      }
    end

    def order_uuid
      'order_uuid'
    end

    def order_number
      'order_number'
    end
  end
end
