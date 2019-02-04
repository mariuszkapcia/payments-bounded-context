require_dependency 'payments'

module Payments
  RSpec.describe 'OnRefundPayment command handler' do
    specify 'refund payment' do
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
      command_bus.call(RefundPayment.new(
        transaction_identifier: transaction_identifier,
        amount:                 amount
      ))

      expect(event_store).to(have_published(refund_succeeded))
    end

    private

    def refund_succeeded
      an_event(Payments::RefundSucceeded).with_data(refund_succeeded_data).strict
    end

    def refund_succeeded_data
      {
        transaction_identifier:                 transaction_identifier,
        payment_gateway_identifier:             kind_of(String),
        payment_gateway_transaction_identifier: kind_of(String),
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
        bus.register(CaptureAuthorization, OnCaptureAuthorization.new(event_store))
        bus.register(RefundPayment, OnRefundPayment.new(event_store))
      end
    end
  end
end
