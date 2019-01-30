module Orders
end

require_dependency 'orders/aggregates/order.rb'

require_dependency 'orders/command_handlers/on_submit_order.rb'
require_dependency 'orders/command_handlers/on_cancel_order.rb'
require_dependency 'orders/command_handlers/on_ship_order.rb'

require_dependency 'orders/commands/submit_order.rb'
require_dependency 'orders/commands/cancel_order.rb'
require_dependency 'orders/commands/ship_order.rb'

require_dependency 'orders/domain_events/order_submitted.rb'
require_dependency 'orders/domain_events/order_cancelled.rb'
require_dependency 'orders/domain_events/order_shipped.rb'

require_dependency 'orders/domain_services/order_number_generator.rb'
