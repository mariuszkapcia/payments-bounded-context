module Payments
  class ChoosePrimaryPaymentGateway
    include Command

    attr_accessor :payment_gateway_identifier

    def initialize(payment_gateway_identifier:)
      @payment_gateway_identifier = payment_gateway_identifier
    end
  end
end
