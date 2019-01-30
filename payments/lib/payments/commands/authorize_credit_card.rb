module Payments
  class AuthorizeCreditCard
    include Command

    attr_accessor :credit_card_token
    attr_accessor :amount
    attr_accessor :order_number

    def initialize(credit_card_token:, amount:, order_number:)
      @credit_card_token = credit_card_token
      @amount            = amount
      @order_number      = order_number
    end
  end
end
