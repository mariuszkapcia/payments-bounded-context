require_dependency 'payments'

module Payments
  RSpec.describe 'OnAuthorizeCreditCard command handler' do
    specify 'authorize payment' do
      command_bus = command_bus_factory
      command_bus.call(AuthorizeCreditCard.new(
        transaction_identifier: transaction_identifier,
        credit_card_token:      credit_card_token,
        amount:                 amount,
        currency:               currency,
        order_number:           order_number
      ))

      expect(event_store).to(have_published(authorization_succeeded))
    end

    private

    def authorization_succeeded
      an_event(Payments::AuthorizationSucceeded).with_data(authorization_succeeded_data).strict
    end

    def authorization_succeeded_data
      {
        transaction_identifier:                 transaction_identifier,
        payment_gateway_transaction_identifier: kind_of(String),
        payment_gateway_identifier:             kind_of(String),
        order_number:                           order_number,
        amount:                                 amount,
        currency:                               currency
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
      end
    end
  end
end
