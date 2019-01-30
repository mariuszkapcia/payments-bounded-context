module Payments
  class AuthorizeCreditCard
    include Command

    attr_accessor :credit_card_token
    attr_accessor :amount
    attr_accessor :currency
    attr_accessor :order_number

    def initialize(credit_card_token:, amount:, currency:, order_number:)
      @credit_card_token = credit_card_token
      @amount            = amount
      @currency          = currency
      @order_number      = order_number
    end
  end
end
