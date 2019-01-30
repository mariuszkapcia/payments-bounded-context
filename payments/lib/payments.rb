module Payments
end

require_dependency 'payments/commands/authorize_credit_card.rb'

require_dependency 'payments/domain_events/credit_card_authorization_succeeded.rb'
require_dependency 'payments/domain_events/credit_card_authorization_failed.rb'
