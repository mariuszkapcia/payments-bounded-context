module Payments
  class MastercardPaymentGateway
    # NOTE: We need it because we have a fake payment gateway and we need a place to store transactions information.
    class Transaction < ActiveRecord::Base
      self.table_name = 'mastercard_payment_gateway_transactions'
    end
    private_constant :Transaction

    def authorize(credit_card_token, amount, currency)
      transaction_identifier = SecureRandom.hex(25)
      Transaction.create!(
        identifier:        transaction_identifier,
        credit_card_token: credit_card_token,
        amount:            amount,
        currency:          currency,
        state:             'authorized'
      )
      transaction_identifier
    end

    def capture(transaction_identifier)
      transaction = Transaction.find_by(identifier: transaction_identifier, state: 'authorized')
      raise PaymentGatewayCaptureFailed unless transaction
      transaction.state = 'captured'
      transaction.save!
      true
    end

    def void(transaction_identifier)
      transaction = Transaction.find_by(identifier: transaction_identifier, state: 'authorized')
      raise PaymentGatewayVoidFailed unless transaction
      transaction.state = 'voided'
      transaction.save!
      true
    end

    def refund(transaction_identifier, amount)
      transaction = Transaction.find_by(identifier: transaction_identifier, state: ['captured', 'refunded'])
      raise PaymentGatewayRefundFailed unless transaction
      transaction.state = 'refunded'
      transaction.save!
      true
    end

    def identifier
      'mastercard'
    end
  end
end
