module Payments
  module Fakes
    class PaymentGatewayList
      def fetch_primary
        @payment_gateway_list.first
      end

      def find(identifier)
        @payment_gateway_list.first
      end

      def break
        @payment_gateway_list.each do |payment_gateway|
          payment_gateway.break
        end
      end

      private

      def initialize(broken: false)
        @payment_gateway_list = [PaymentGateway.new(broken: broken)]
      end
    end

    class PaymentGateway
      def authorize(credit_card_token, amount, currency)
        raise PaymentGatewayAuthorizationFailed if @broken
        'payment_gateway_transaction_identifier'
      end

      def capture(transaction_identifier)
        raise PaymentGatewayCaptureFailed if @broken
        true
      end

      def void(transaction_identifier)
        raise PaymentGatewayVoidFailed if @broken
        true
      end

      def refund(transaction_identifier, amount)
        raise PaymentGatewayRefundFailed if @broken
        true
      end

      def identifier
        'fake'
      end

      def break
        @broken = true
      end

      private

      def initialize(broken: false)
        @broken = broken
      end
    end
  end
end
