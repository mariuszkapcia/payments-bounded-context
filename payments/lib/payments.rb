module Payments
end

require_dependency 'payments/aggregates/credit_card_payment.rb'
require_dependency 'payments/aggregates/payment_gateway_configuration.rb'

require_dependency 'payments/command_handlers/on_authorize_credit_card.rb'
require_dependency 'payments/command_handlers/on_capture_authorization.rb'
require_dependency 'payments/command_handlers/on_void_authorization.rb'
require_dependency 'payments/command_handlers/on_refund_payment.rb'
require_dependency 'payments/command_handlers/on_register_payment_gateway.rb'
require_dependency 'payments/command_handlers/on_choose_primary_payment_gateway.rb'
require_dependency 'payments/command_handlers/on_switch_to_fallback_payment_gateway.rb'

require_dependency 'payments/commands/authorize_credit_card.rb'
require_dependency 'payments/commands/capture_authorization.rb'
require_dependency 'payments/commands/void_authorization.rb'
require_dependency 'payments/commands/refund_payment.rb'
require_dependency 'payments/commands/register_payment_gateway.rb'
require_dependency 'payments/commands/choose_primary_payment_gateway.rb'
require_dependency 'payments/commands/switch_to_fallback_payment_gateway.rb'

require_dependency 'payments/domain_events/authorization_succeeded.rb'
require_dependency 'payments/domain_events/authorization_failed.rb'
require_dependency 'payments/domain_events/capture_succeeded.rb'
require_dependency 'payments/domain_events/capture_failed.rb'
require_dependency 'payments/domain_events/void_succeeded.rb'
require_dependency 'payments/domain_events/void_failed.rb'
require_dependency 'payments/domain_events/refund_succeeded.rb'
require_dependency 'payments/domain_events/refund_failed.rb'
require_dependency 'payments/domain_events/payment_gateway_registered.rb'
require_dependency 'payments/domain_events/primary_payment_gateway_chosen.rb'
require_dependency 'payments/domain_events/payment_gateway_switched_to_fallback.rb'

require_dependency 'payments/domain_services/visa_payment_gateway.rb'
require_dependency 'payments/domain_services/mastercard_payment_gateway.rb'

require_dependency 'payments/read_models/payment_gateway_list/payment_gateway_list_read_model.rb'
require_dependency 'payments/read_models/payment_gateway_list/payment_gateway.rb'
