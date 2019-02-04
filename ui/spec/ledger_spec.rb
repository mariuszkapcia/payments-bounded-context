require_dependency 'ui'

module UI
  RSpec.describe 'Ledger read model' do
    specify 'normal flow of events' do
      read_model.call(authorization_succeeded)
      expect(read_model.all.size).to eq(1)
      assert_authorized_transaction

      read_model.call(capture_succeeded)
      expect(read_model.all.size).to eq(2)
      assert_captured_transaction
    end

    private

    def assert_authorized_transaction
      expect(first_transaction.order_number).to eq(order_number)
      expect(first_transaction.amount).to eq(amount)
      expect(first_transaction.currency).to eq(currency)
      expect(first_transaction.identifier).to eq(transaction_identifier)
      expect(first_transaction.payment_gateway_identifier).to eq(payment_gateway_identifier)
      expect(first_transaction.payment_gateway_transaction_identifier).to eq(payment_gateway_transaction_identifier)
      expect(first_transaction.entry_type).to eq('authorization')
    end

    def assert_captured_transaction
      expect(second_transaction.order_number).to eq(order_number)
      expect(second_transaction.amount).to eq(amount)
      expect(second_transaction.currency).to eq(currency)
      expect(second_transaction.identifier).to eq(transaction_identifier)
      expect(second_transaction.payment_gateway_identifier).to eq(payment_gateway_identifier)
      expect(second_transaction.payment_gateway_transaction_identifier).to eq(payment_gateway_transaction_identifier)
      expect(second_transaction.entry_type).to eq('capture')
    end

    def authorization_succeeded
      Payments::AuthorizationSucceeded.new(data: {
        transaction_identifier:                 transaction_identifier,
        payment_gateway_transaction_identifier: payment_gateway_transaction_identifier,
        payment_gateway_identifier:             payment_gateway_identifier,
        order_number:                           order_number,
        amount:                                 amount,
        currency:                               currency
      })
    end

    def capture_succeeded
      Payments::CaptureSucceeded.new(data: {
        transaction_identifier:                 transaction_identifier,
        payment_gateway_transaction_identifier: payment_gateway_transaction_identifier,
        payment_gateway_identifier:             payment_gateway_identifier,
        order_number:                           order_number,
        amount:                                 amount,
        currency:                               currency
      })
    end

    def order_uuid
      'order_uuid'
    end

    def order_number
      'order_number'
    end

    def amount
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

    def read_model
      @ledger_read_model ||= UI::LedgerReadModel.new
    end

    def first_transaction
      read_model.all.first
    end

    def second_transaction
      read_model.all.second
    end
  end
end
