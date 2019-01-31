module Payments
  class RegisterPaymentGateway
    include Command

    attr_accessor :payment_gateway_identifier
    attr_accessor :adapter
    attr_accessor :fallback_identifier

    def initialize(payment_gateway_identifier:, adapter:, fallback_identifier:)
      @payment_gateway_identifier = payment_gateway_identifier
      @adapter                    = adapter
      @fallback_identifier        = fallback_identifier
    end
  end
end
