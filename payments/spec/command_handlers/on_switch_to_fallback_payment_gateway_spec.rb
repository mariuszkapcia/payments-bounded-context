require_dependency 'payments'

require_relative '../support/fakes'

module Payments
  RSpec.describe 'OnSwitchToFallbackPaymentGateway command handler' do
    include Fakes

    specify 'register payment gateway' do
      command_bus = command_bus_factory
      command_bus.call(RegisterPaymentGateway.new(
        payment_gateway_identifier: payment_gateway_identifier,
        adapter:                    adapter,
        fallback_identifier:        fallback_identifier
      ))
      command_bus.call(SwitchToFallbackPaymentGateway.new(
        payment_gateway_identifier: payment_gateway_identifier
      ))

      expect(event_store).to(have_published(payment_gateway_swtiched_to_fallback))
    end

    private

    def payment_gateway_swtiched_to_fallback
      an_event(Payments::PaymentGatewaySwitchedToFallback).with_data(payment_gateway_swtiched_to_fallback_data).strict
    end

    def payment_gateway_swtiched_to_fallback_data
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
        bus.register(SwitchToFallbackPaymentGateway, OnSwitchToFallbackPaymentGateway.new(event_store))
      end
    end
  end
end
