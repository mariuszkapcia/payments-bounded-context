module Payments
  class CreditCardPayment
    include AggregateRoot

    InvalidOperation = Class.new(StandardError)

    # NOTE: We need to pass payment_gateway_list instead of payment_gateway instance because it's possible to use
    #       different payment gateways at different states. If we authorize payment with one payment gateway then
    #       we have to capture or void it with the same payment gateway. In the meantime this payment gateway
    #       can be switched to fallback payment gateway and we want to start new payments with fallback gateway.
    # NOTE: Another approach would to add payment_gateway_identifier to the CaptureAuthorization and
    #       VoidAuthorization commands. Thanks to that, we can fetch appropriate payment gateway in the command
    #       handler.
    def initialize(transaction_identifier, payment_gateway_list:)
      @transaction_identifier                 = transaction_identifier
      @payment_gateway_transaction_identifier = nil
      @payment_gateway_identifier             = nil
      @payment_gateway_list                   = payment_gateway_list
      @order_number                           = nil
      @amount                                 = 0
      @refunded_amount                        = 0
      @currency                               = nil
      @state                                  = :none
    end

    def authorize(credit_card_token, amount, currency, order_number)
      raise InvalidOperation if authorized?

      payment_gateway = @payment_gateway_list.fetch_primary
      payment_gateway_transaction_identifier = payment_gateway.authorize(credit_card_token, amount, currency)

      apply(Payments::AuthorizationSucceeded.strict(data: {
        transaction_identifier:                 @transaction_identifier,
        payment_gateway_transaction_identifier: payment_gateway_transaction_identifier,
        payment_gateway_identifier:             payment_gateway.identifier,
        order_number:                           order_number,
        amount:                                 amount,
        currency:                               currency
      }))
    rescue PaymentGatewayAuthorizationFailed
      apply(Payments::AuthorizationFailed.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: payment_gateway.identifier,
        order_number:               order_number
      }))
    end

    # NOTE: We can pass amount and curreny here to support multi captures if needed.
    def capture
      raise InvalidOperation unless authorized?
      raise InvalidOperation if captured?

      payment_gateway = @payment_gateway_list.find(@payment_gateway_identifier)
      payment_gateway.capture(@payment_gateway_transaction_identifier)

      apply(Payments::CaptureSucceeded.strict(data: {
        transaction_identifier:                 @transaction_identifier,
        payment_gateway_identifier:             payment_gateway.identifier,
        payment_gateway_transaction_identifier: @payment_gateway_transaction_identifier,
        order_number:                           @order_number,
        amount:                                 @amount,
        currency:                               @currency
      }))
    rescue PaymentGatewayCaptureFailed
      apply(Payments::CaptureFailed.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: payment_gateway.identifier,
        order_number:               @order_number
      }))
    end

    def void
      raise InvalidOperation unless authorized?
      raise InvalidOperation if voided?

      payment_gateway = @payment_gateway_list.find(@payment_gateway_identifier)
      payment_gateway.void(@payment_gateway_transaction_identifier)

      apply(Payments::VoidSucceeded.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: payment_gateway.identifier,
        order_number:               @order_number
      }))
    rescue PaymentGatewayVoidFailed
      apply(Payments::VoidFailed.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: payment_gateway.identifier,
        order_number:               @order_number
      }))
    end

    def refund(amount)
      raise InvalidOperation unless captured? || refunded?
      raise InvalidOperation if @refunded_amount + amount > @amount

      @payment_gateway.refund(@payment_gateway_transaction_identifier, amount)

      apply(Payments::RefundSucceeded.strict(data: {
        transaction_identifier:                 @transaction_identifier,
        payment_gateway_identifier:             @payment_gateway.identifier,
        payment_gateway_transaction_identifier: @payment_gateway_transaction_identifier,
        order_number:                           @order_number,
        amount:                                 amount,
        currency:                               @currency
      }))
    rescue PaymentGatewayRefundFailed
      apply(Payments::RefundFailed.strict(data: {
        transaction_identifier:     @transaction_identifier,
        payment_gateway_identifier: @payment_gateway.identifier,
        order_number:               @order_number
      }))
    end

    private

    def authorized?
      @state == :authorized
    end

    def captured?
      @state == :captured
    end

    def voided?
      @state == :voided
    end

    def refunded?
      @state == :refunded
    end

    def apply_authorization_succeeded(event)
      @transaction_identifier                 = event.data[:transaction_identifier]
      @payment_gateway_transaction_identifier = event.data[:payment_gateway_transaction_identifier]
      @payment_gateway_identifier             = event.data[:payment_gateway_identifier]
      @order_number                           = event.data[:order_number]
      @amount                                 = event.data[:amount]
      @currency                               = event.data[:currency]
      @state                                  = :authorized
    end

    def apply_authorization_failed(event)
    end

    def apply_capture_succeeded(event)
      @state = :captured
    end

    def apply_capture_failed(event)
    end

    def apply_void_succeeded(event)
      @state = :voided
    end

    def apply_void_failed(event)
    end

    def apply_refund_succeeded(event)
      @refunded_amount += event.data[:amount]
      @state            = :refunded
    end

    def apply_refund_failed(event)
    end
  end
end
