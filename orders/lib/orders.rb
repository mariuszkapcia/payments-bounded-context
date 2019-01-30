module Orders
end

require_dependency 'orders/aggregates/order.rb'

require_dependency 'orders/domain_events/order_submitted.rb'
