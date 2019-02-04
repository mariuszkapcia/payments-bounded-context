module Payments
  class RefundPayment
    include Command

    attr_accessor :transaction_identifier
    attr_accessor :amount

    def initialize(transaction_identifier:, amount:)
      @transaction_identifier = transaction_identifier
      @amount                 = amount
    end
  end
end
