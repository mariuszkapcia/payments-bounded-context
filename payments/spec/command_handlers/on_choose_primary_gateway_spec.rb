require_dependency 'payments'

require_relative '../support/fakes'

module Payments
  RSpec.describe 'OnChoosePrimaryPaymentGateway command handler' do
    include Fakes

    specify 'register payment gateway' do
      command_bus = command_bus_factory
      command_bus.call(RegisterPaymentGateway.new(
        payment_gateway_identifier: payment_gateway_identifier,
        adapter:                    adapter,
        fallback_identifier:        fallback_identifier
      ))
      command_bus.call(ChoosePrimaryPaymentGateway.new(
        payment_gateway_identifier: payment_gateway_identifier
      ))

      expect(event_store).to(have_published(primary_payment_gateway_chosen))
    end

    private

    def primary_payment_gateway_chosen
      an_event(Payments::PrimaryPaymentGatewayChosen).with_data(primary_payment_gateway_chosen_data).strict
    end

    def primary_payment_gateway_chosen_data
      {
        payment_gateway_identifier: payment_gateway_identifier
      }
    end

    def payment_gateway_identifier
      'payment_gateway_identifier'
    end

    def adapter
      'adapter'
    end

    def fallback_identifier
      'fallback_identifier'
    end

    def event_store
      @event_store ||= begin
        RailsEventStore::Client.new(repository: RubyEventStore::InMemoryRepository.new)
      end
    end

    def command_bus_factory
      Arkency::CommandBus.new.tap do |bus|
        bus.register(RegisterPaymentGateway, OnRegisterPaymentGateway.new(event_store))
        bus.register(ChoosePrimaryPaymentGateway, OnChoosePrimaryPaymentGateway.new(event_store))
      end
    end
  end
end
