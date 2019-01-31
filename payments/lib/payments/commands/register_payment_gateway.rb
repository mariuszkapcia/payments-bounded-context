module Payments
  class RegisterPaymentGateway
    include Command

    attr_accessor :payment_gateway_identifier
    attr_accessor :adapter
    attr_accessor :fallback_adapter

    def initialize(payment_gateway_identifier:, adapter:, fallback_adapter:)
      @payment_gateway_identifier = payment_gateway_identifier
      @adapter                    = adapter
      @fallback_adapter           = fallback_adapter
    end
  end
end
