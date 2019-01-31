command_bus = Rails.configuration.command_bus
command_bus.call(
  Payments::RegisterPaymentGateway.new(
    payment_gateway_identifier: 'visa',
    adapter:                    'Payments::VisaPaymentGateway',
    fallback_identifier:        'MastercardPaymentGateway'
  )
)
command_bus.call(
  Payments::RegisterPaymentGateway.new(
    payment_gateway_identifier: 'mastercard',
    adapter:                    'Payments::MastercardPaymentGateway',
    fallback_identifier:        nil
  )
)
command_bus.call(Payments::ChoosePrimaryPaymentGateway.new(payment_gateway_identifier: 'visa'))
