module Payments
  module PaymentGatewayList
    class PaymentGateway < ActiveRecord::Base
      self.table_name = 'payments_payment_gateway_list_read_model'
    end
  end
end
