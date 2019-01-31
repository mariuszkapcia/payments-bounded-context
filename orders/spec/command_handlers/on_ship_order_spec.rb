require_dependency 'orders'

module Orders
  RSpec.describe 'OnShipOrder command handler' do
    specify 'ship order' do
      command_bus = command_bus_factory
      command_bus.call(SubmitOrder.new(
        order_uuid: order_uuid
      ))
      command_bus.call(ShipOrder.new(
        order_uuid: order_uuid
      ))

      expect(event_store).to(have_published(order_shipped))
    end

    private

    def order_shipped
      an_event(Orders::OrderShipped).with_data(order_shipped_data).strict
    end

    def order_shipped_data
      {
        order_uuid:   order_uuid,
        order_number: kind_of(String)
      }
    end

    def order_uuid
      'order_uuid'
    end

    def event_store
      @event_store ||= begin
        RailsEventStore::Client.new(repository: RubyEventStore::InMemoryRepository.new)
      end
    end

    def command_bus_factory
      Arkency::CommandBus.new.tap do |bus|
        bus.register(SubmitOrder, OnSubmitOrder.new(event_store))
        bus.register(ShipOrder, OnShipOrder.new(event_store))
      end
    end
  end
end
