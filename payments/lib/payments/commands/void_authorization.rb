module Payments
  class VoidAuthorization
    include Command

    attr_accessor :transaction_identifier

    def initialize(transaction_identifier:)
      @transaction_identifier = transaction_identifier
    end
  end
end
