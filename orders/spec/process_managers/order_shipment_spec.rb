require_dependency 'orders'

module Orders
  RSpec.describe 'OrderShipment process manager' do
    specify 'ship order' do
      command_bus = FakeCommandBus.new
      process     = OrderShipment.new(event_store: event_store, command_bus: command_bus)
      given([
        order_submitted,
        authorization_succeeded
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(1)
      expect(command_bus.commands.first.as_json).to eq(ship_order.as_json)
    end

    specify 'order is shipped only once' do
      command_bus = FakeCommandBus.new
      process     = OrderShipment.new(event_store: event_store, command_bus: command_bus)
      given([
        order_submitted,
        authorization_succeeded,
        order_shipped
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(1)
      expect(command_bus.commands.first.as_json).to eq(ship_order.as_json)
    end

    specify 'order is not shipped if payment failed' do
      command_bus = FakeCommandBus.new
      process     = OrderShipment.new(event_store: event_store, command_bus: command_bus)
      given([
        order_submitted,
        authorization_failed
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(0)
    end

    specify 'order is not shipped if order was cancelled' do
      command_bus = FakeCommandBus.new
      process     = OrderShipment.new(event_store: event_store, command_bus: command_bus)
      given([
        order_submitted,
        order_cancelled,
        authorization_succeeded
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(0)
    end

    private

    class FakeCommandBus
      attr_reader :commands

      def call(command)
        @commands.push(command)
      end

      def initialize
        @commands = []
      end
    end

    def event_store
      @event_store ||= begin
        RailsEventStore::Client.new(repository: RubyEventStore::InMemoryRepository.new)
      end
    end

    def given(events)
      events.each { |ev| event_store.append(ev) }
      events
    end

    def order_submitted
      Orders::OrderSubmitted.new(data: {
        order_uuid:   order_uuid,
        order_number: order_number,
        gross_value:  gross_value,
        currency:     currency
        })
    end

    def order_shipped
      Orders::OrderShipped.new(data: {
        order_uuid:   order_uuid,
        order_number: order_number
      })
    end

    def order_cancelled
      Orders::OrderCancelled.new(data: {
        order_uuid:   order_uuid,
        order_number: order_number
      })
    end

    def authorization_succeeded
      Payments::AuthorizationSucceeded.new(data: {
        transaction_identifier:                 transaction_identifier,
        payment_gateway_transaction_identifier: payment_gateway_transaction_identifier,
        payment_gateway_identifier:             payment_gateway_identifier,
        order_number:                           order_number
      })
    end

    def authorization_failed
      Payments::AuthorizationFailed.new(data: {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: payment_gateway_identifier,
        order_number:               order_number
      })
    end

    def ship_order
      Orders::ShipOrder.new(order_uuid: order_uuid)
    end

    def order_uuid
      'order_uuid'
    end

    def order_number
      'order_number'
    end

    def gross_value
      100
    end

    def currency
      'USD'
    end

    def transaction_identifier
      'transaction_identifier'
    end

    def payment_gateway_transaction_identifier
      'payment_gateway_transaction_identifier'
    end

    def payment_gateway_identifier
      'payment_gateway_identifier'
    end
  end
end
