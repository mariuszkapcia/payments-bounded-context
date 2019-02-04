module UI
  # NOTE: We probably want to also handle here VoidSucceeded to show that authorization has been released.
  class LedgerReadModel
    def call(event)
      case event
      when Payments::AuthorizationSucceeded
        add_transaction(
          order_data: {
            order_number: event.data[:order_number],
            amount:       event.data[:amount],
            currency:     event.data[:currency]
          },
          transaction_data: {
            transaction_identifier:                 event.data[:transaction_identifier],
            payment_gateway_identifier:             event.data[:payment_gateway_identifier],
            payment_gateway_transaction_identifier: event.data[:payment_gateway_transaction_identifier],
            type:                                   'authorization'
          },
          timestamp: event.metadata[:time]
        )
      when Payments::CaptureSucceeded
        add_transaction(
          order_data: {
            order_number: event.data[:order_number],
            amount:       event.data[:amount],
            currency:     event.data[:currency]
          },
          transaction_data: {
            transaction_identifier:                 event.data[:transaction_identifier],
            payment_gateway_identifier:             event.data[:payment_gateway_identifier],
            payment_gateway_transaction_identifier: event.data[:payment_gateway_transaction_identifier],
            type:                                   'capture'
          },
          timestamp: event.metadata[:time]
        )
      when Payments::RefundSucceeded
        add_transaction(
          order_data: {
            order_number: event.data[:order_number],
            amount:       -event.data[:amount],
            currency:     event.data[:currency]
          },
          transaction_data: {
            transaction_identifier:                 event.data[:transaction_identifier],
            payment_gateway_identifier:             event.data[:payment_gateway_identifier],
            payment_gateway_transaction_identifier: event.data[:payment_gateway_transaction_identifier],
            type:                                   'refund'
          },
          timestamp: event.metadata[:time]
        )
      end
    end

    def all
      UI::Ledger::Transaction.all
    end

    private

    def add_transaction(order_data:, transaction_data:, timestamp:)
      UI::Ledger::Transaction.create!(
        order_number:                           order_data[:order_number],
        amount:                                 order_data[:amount],
        currency:                               order_data[:currency],
        identifier:                             transaction_data[:transaction_identifier],
        payment_gateway_identifier:             transaction_data[:payment_gateway_identifier],
        payment_gateway_transaction_identifier: transaction_data[:payment_gateway_transaction_identifier],
        entry_type:                             transaction_data[:type],
        timestamp:                              timestamp
      )
    end
  end
end
