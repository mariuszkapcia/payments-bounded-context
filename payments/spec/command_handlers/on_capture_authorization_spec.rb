require_dependency 'payments'

module Payments
  RSpec.describe 'OnCaptureAuthorization command handler' do
    specify 'capture authorization' do
      command_bus = command_bus_factory
      command_bus.call(AuthorizeCreditCard.new(
        transaction_identifier: transaction_identifier,
        credit_card_token:      credit_card_token,
        amount:                 amount,
        currency:               currency,
        order_number:           order_number
      ))
      command_bus.call(CaptureAuthorization.new(
        transaction_identifier: transaction_identifier
      ))

      expect(event_store).to(have_published(capture_succeeded))
    end

    private

    def capture_succeeded
      an_event(Payments::CaptureSucceeded).with_data(capture_succeeded_data).strict
    end

    def capture_succeeded_data
      {
        transaction_identifier:     transaction_identifier,
        payment_gateway_identifier: kind_of(String),
        order_number:               order_number
      }
    end

    def transaction_identifier
      'transaction_identifier'
    end

    def credit_card_token
      'credit_card_token'
    end

    def amount
      0
    end

    def currency
      'USD'
    end

    def order_number
      'order_number'
    end

    def event_store
      @event_store ||= begin
        RailsEventStore::Client.new(repository: RubyEventStore::InMemoryRepository.new)
      end
    end

    def command_bus_factory
      Arkency::CommandBus.new.tap do |bus|
        bus.register(AuthorizeCreditCard, OnAuthorizeCreditCard.new(event_store))
        bus.register(CaptureAuthorization, OnCaptureAuthorization.new(event_store))
      end
    end
  end
end
