# Payments bounded context

Sample application showing an implementation of simple payments bounded context in Ruby on Rails.

Content:
- There is no UI or application layer. If you want to see sample implementation of UI/application layer you can check out my other sample application [project-management-app](https://github.com/mariuszkapcia/project-management-app).
- Payments bounded context.
- Orders bounded context.
- Order fulfillment process manager.
- Order shipment process manager.
- UI bounded context with Ledger read model.

On **feature/payment-gateway-switcher-process-manager** branch you can see more complex version with dynamic list of payment gateways and payment gateway switcher process manager. This process is responsible for checking if payment gateway is operational and if not then switching to fallback payment gateway.

Sticky notes representation: https://realtimeboard.com/welcomeonboard/UJmEbjYX4gtFkeUfz66zcIFbNxdxLhQPoRUv2hpuU24AX4fFd0E2ED3p3o59qJg8

Sticky notes representation (with payment gateway switcher): https://realtimeboard.com/welcomeonboard/F7sL6fnDxxP7EqHqY52OVBcmLrRn5xpQJXl6ywMKbt8O5YBksf0CqHfHdkyNSZNw
