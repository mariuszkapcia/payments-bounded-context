require_dependency 'payments'

require_relative '../support/fakes'

module Payments
  RSpec.describe 'OnVoidAuthorization command handler' do
    include Fakes

    specify 'void authorization' do
      command_bus = command_bus_factory(payment_gateway_list: Fakes::PaymentGatewayList.new)
      command_bus.call(AuthorizeCreditCard.new(
        transaction_identifier: transaction_identifier,
        credit_card_token:      credit_card_token,
        amount:                 amount,
        currency:               currency,
        order_number:           order_number
      ))
      command_bus.call(VoidAuthorization.new(
        transaction_identifier: transaction_identifier
      ))

      expect(event_store).to(have_published(void_succeeded))
    end

    private

    class FakePaymentGateway
      def authorize(credit_card_token, amount, currency)
        'payment_gateway_transaction_identifier'
      end

      def void(transaction_identifier)
      end

      def identifier
        'fake'
      end
    end

    class FakePaymentGatewayList
      def fetch_primary
        FakePaymentGateway.new
      end

      def find(identifier)
        FakePaymentGateway.new
      end
    end

    def void_succeeded
      an_event(Payments::VoidSucceeded).with_data(void_succeeded_data).strict
    end

    def void_succeeded_data
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

    def command_bus_factory(payment_gateway_list:)
      Arkency::CommandBus.new.tap do |bus|
        bus.register(AuthorizeCreditCard, OnAuthorizeCreditCard.new(
          event_store,
          payment_gateway_list: payment_gateway_list
        ))
        bus.register(VoidAuthorization, OnVoidAuthorization.new(
          event_store,
          payment_gateway_list: payment_gateway_list
        ))
      end
    end
  end
end
