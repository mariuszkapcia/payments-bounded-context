module UI
  class LedgerReadModel
    def call(event)
      case event
      when Payments::AuthorizationSucceeded
        add_transaction(
          event.data[:transaction_identifier],
          event.data[:payment_gateway_transaction_identifier],
          event.data[:amount],
          event.data[:currency],
          event.metadata[:timestamp]
        )
      when Payments::CaptureSucceeded
        capture_transaction(event.data[:transaction_identifier])
      end
    end

    def all
      UI::Ledger::Transaction.where(state: 'captured')
    end

    private

    def add_transaction(transaction_identifier, payment_gateway_transaction_identifier, amount, currency, timestamp)
      UI::Ledger::Transaction.create!(
        identifier:                             transaction_identifier,
        payment_gateway_transaction_identifier: payment_gateway_transaction_identifier,
        amount:                                 amount,
        currency:                               currency,
        timestamp:                              timestamp,
        state:                                  'authorized'
      )
    end

    def capture_transaction(transaction_identifier)
      transaction       = UI::Ledger::Transaction.find_by(identifier: transaction_identifier, state: 'authorized')
      transaction.state = 'captured'
      transaction.save!
    end
  end
end
