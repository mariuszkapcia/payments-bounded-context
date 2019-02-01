require_dependency 'payments'

module Payments
  RSpec.describe 'PaymentGatewaySwitcher process manager' do
    specify 'switch payment gateway to fallback' do
      command_bus = FakeCommandBus.new
      process     = PaymentGatewaySwitcher.new(
        event_store:            event_store,
        command_bus:            command_bus,
        fallback_configuration: fallback_configuration
      )
      given([
        authorization_succeeded,
        capture_failed,
        capture_failed,
        capture_failed,
        capture_failed
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(1)
      expect(command_bus.commands.first.as_json).to eq(switch_to_fallback_payment_gateway.as_json)
    end

    specify 'first success reset failure counter' do
      command_bus = FakeCommandBus.new
      process     = PaymentGatewaySwitcher.new(
        event_store:            event_store,
        command_bus:            command_bus,
        fallback_configuration: fallback_configuration
      )
      given([
        authorization_succeeded,
        capture_failed,
        capture_failed,
        capture_failed,
        authorization_succeeded,
        capture_failed
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(0)
    end

    specify 'fallback payment gateway has own failure counter from 0' do
      command_bus = FakeCommandBus.new
      process     = PaymentGatewaySwitcher.new(
        event_store:            event_store,
        command_bus:            command_bus,
        fallback_configuration: fallback_configuration
      )
      given([
        authorization_succeeded,
        capture_failed,
        capture_failed,
        capture_failed,
        capture_failed,
        authorization_failed_from_fallback
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(1)
      expect(command_bus.commands.first.as_json).to eq(switch_to_fallback_payment_gateway.as_json)
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

    def authorization_failed_from_fallback
      Payments::AuthorizationFailed.new(data: {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: fallback_payment_gateway_identifier,
        order_number:               order_number
      })
    end

    def capture_succeeded
      Payments::CaptureSucceeded.new(data: {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: payment_gateway_identifier,
        order_number:               order_number
      })
    end

    def capture_failed
      Payments::CaptureFailed.new(data: {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: payment_gateway_identifier,
        order_number:               order_number
      })
    end

    def void_succeeded
      Payments::VoidSucceeded.new(data: {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: payment_gateway_identifier,
        order_number:               order_number
      })
    end

    def void_failed
      Payments::VoidFailed.new(data: {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: payment_gateway_identifier,
        order_number:               order_number
      })
    end

    def switch_to_fallback_payment_gateway
      Payments::SwitchToFallbackPaymentGateway.new(payment_gateway_identifier: payment_gateway_identifier)
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

    def fallback_payment_gateway_identifier
      'fallback_payment_gateway_identifier'
    end

    def order_number
      'order_number'
    end

    def fallback_configuration
      OpenStruct.new(
        max_failed_payments_count: 3
      )
    end
  end
end
