module UI
  class LedgerReadModel
    def call(event)
      case event
      when Orders::OrderSubmitted
        add_order(event.data[:order_number], event.data[:gross_value], event.data[:currency])
      when Payments::AuthorizationSucceeded
        add_transaction_information(
          event.data[:order_number],
          event.data[:transaction_identifier],
          event.data[:payment_gateway_identifier],
          event.data[:payment_gateway_transaction_identifier]
        )
      when Payments::CaptureSucceeded
        capture_transaction(event.data[:transaction_identifier], event.metadata[:timestamp])
      end
    end

    def all
      UI::Ledger::Transaction.where(state: 'captured')
    end

    private

    def add_order(order_number, amount, currency)
      UI::Ledger::Transaction.create!(order_number: order_number, amount: amount, currency: currency)
    end

    def add_transaction_information(order_number, trx_identifier, gateway_identifier, gateway_trx_identifier)
      transaction = UI::Ledger::Transaction.find_by(order_number: order_number)

      transaction.identifier                             = trx_identifier
      transaction.payment_gateway_identifier             = gateway_identifier
      transaction.payment_gateway_transaction_identifier = gateway_trx_identifier
      transaction.state                                  = 'authorized'

      transaction.save!
    end

    def capture_transaction(transaction_identifier, timestamp)
      transaction       = UI::Ledger::Transaction.find_by(identifier: transaction_identifier, state: 'authorized')

      transaction.state     = 'captured'
      transaction.timestamp = timestamp

      transaction.save!
    end
  end
end
