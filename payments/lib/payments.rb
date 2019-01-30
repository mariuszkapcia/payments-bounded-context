module Payments
end

require_dependency 'payments/aggregates/credit_card_payment.rb'

require_dependency 'payments/command_handlers/on_authorize_credit_card.rb'
require_dependency 'payments/command_handlers/on_capture_authorization.rb'

require_dependency 'payments/commands/authorize_credit_card.rb'
require_dependency 'payments/commands/capture_authorization.rb'
require_dependency 'payments/commands/void_authorization.rb'

require_dependency 'payments/domain_events/authorization_succeeded.rb'
require_dependency 'payments/domain_events/authorization_failed.rb'
require_dependency 'payments/domain_events/capture_succeeded.rb'
require_dependency 'payments/domain_events/capture_failed.rb'
require_dependency 'payments/domain_events/void_succeeded.rb'
require_dependency 'payments/domain_events/void_failed.rb'

require_dependency 'payments/domain_services/visa_payment_gateway.rb'
require_dependency 'payments/domain_services/mastercard_payment_gateway.rb'
