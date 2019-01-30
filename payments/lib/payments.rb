module Payments
end

require_dependency 'payments/aggregates/credit_card_payment.rb'

require_dependency 'payments/command_handlers/on_authorize_credit_card.rb'

require_dependency 'payments/commands/authorize_credit_card.rb'
require_dependency 'payments/commands/capture_credit_card_authorization.rb'

require_dependency 'payments/domain_events/credit_card_authorization_succeeded.rb'
require_dependency 'payments/domain_events/credit_card_authorization_failed.rb'

require_dependency 'payments/domain_services/visa_payment_gateway.rb'
require_dependency 'payments/domain_services/mastercard_payment_gateway.rb'