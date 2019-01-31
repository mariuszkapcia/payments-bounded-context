require_dependency 'orders'

module Orders
  RSpec.describe 'OnSubmitOrder command handler' do
    specify 'submit order' do
      command_bus = command_bus_factory
      command_bus.call(SubmitOrder.new(
        order_uuid: order_uuid
      ))

      expect(event_store).to(have_published(order_submitted))
    end

    private

    def order_submitted
      an_event(Orders::OrderSubmitted).with_data(order_submitted_data).strict
    end

    def order_submitted_data
      {
        order_uuid:   order_uuid,
        order_number: kind_of(String),
        gross_value:  0,
        currency:     'USD'
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
      end
    end
  end
end
