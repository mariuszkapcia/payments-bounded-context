require_dependency 'orders'

module Orders
  RSpec.describe 'OrderFulfillment process manager' do
    specify 'capture payment for the order' do
      command_bus = FakeCommandBus.new
      process     = OrderFulfillment.new(event_store: event_store, command_bus: command_bus)
      given([
        order_submitted,
        authorization_succeeded,
        order_shipped
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(1)
      expect(command_bus.commands.first.as_json).to eq(capture_authorization.as_json)
    end

    specify 'try again if capture payment failed' do
      command_bus = FakeCommandBus.new
      process     = OrderFulfillment.new(event_store: event_store, command_bus: command_bus)
      given([
        order_submitted,
        authorization_succeeded,
        order_shipped,
        capture_failed
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(2)
      expect(command_bus.commands[0].as_json).to eq(capture_authorization.as_json)
      expect(command_bus.commands[1].as_json).to eq(capture_authorization.as_json)
    end

    specify 'void payment for the order' do
      command_bus = FakeCommandBus.new
      process     = OrderFulfillment.new(event_store: event_store, command_bus: command_bus)
      given([
        order_submitted,
        authorization_succeeded,
        order_cancelled
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(1)
      expect(command_bus.commands.first.as_json).to eq(void_authorization.as_json)
    end

    specify 'try again if void payment failed' do
      command_bus = FakeCommandBus.new
      process     = OrderFulfillment.new(event_store: event_store, command_bus: command_bus)
      given([
        order_submitted,
        authorization_succeeded,
        order_cancelled,
        void_failed
      ]).each do |event|
        process.call(event)
      end

      expect(command_bus.commands.size).to eq(2)
      expect(command_bus.commands[0].as_json).to eq(void_authorization.as_json)
      expect(command_bus.commands[1].as_json).to eq(void_authorization.as_json)
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

    def capture_authorization
      Payments::CaptureAuthorization.new(transaction_identifier: transaction_identifier)
    end

    def void_authorization
      Payments::VoidAuthorization.new(transaction_identifier: transaction_identifier)
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
