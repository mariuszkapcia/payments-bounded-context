module Payments
  class VisaPaymentGateway
    IDENTIFIER = 'visa'.freeze

    # NOTE: We need it because we have a fake payment gateway and we need a place to store transactions information.
    class Transaction < ActiveRecord::Base
      self.table_name = 'visa_payment_gateway_transactions'
    end
    private_constant :Transaction

    AuthorizationFailed = Class.new(StandardError)
    CaptureFailed       = Class.new(StandardError)
    VoidFailed          = Class.new(StandardError)

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
      raise CaptureFailed unless transaction
      transaction.state = 'captured'
      transaction.save!
      true
    end

    def void(transaction_identifier)
      transaction = Transaction.find_by(identifier: transaction_identifier, state: 'authorized')
      raise VoidFailed unless transaction
      transaction.state = 'voided'
      transaction.save!
      true
    end
  end
end
