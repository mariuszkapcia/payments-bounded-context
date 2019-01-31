require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::Client.new
  Rails.configuration.command_bus = command_bus = Arkency::CommandBus.new

  AggregateRoot.configure do |config|
    config.default_event_store = event_store
  end

  # UI bounded context.
  event_store.subscribe(
    UI::LedgerReadModel,
    to: [
      Payments::AuthorizationSucceeded,
      Payments::CaptureSucceeded
    ]
  )

  # Payments bounded context.
  event_store.subscribe(
    Payments::PaymentGatewayListReadModel,
    to: [
      Payments::PaymentGatewayRegistered,
      Payments::PrimaryPaymentGatewayChosen,
      Payments::PaymentGatewaySwitchedToFallback
    ]
  )

  # Process managers.
  event_store.subscribe(
    Orders::OrderShipment.new(event_store: event_store, command_bus: command_bus),
    to: [
      Orders::OrderSubmitted,
      Payments::AuthorizationSucceeded,
      Payments::AuthorizationFailed,
      Orders::OrderCancelled,
      Orders::OrderShipped
    ]
  )

  event_store.subscribe(
    Orders::OrderFulfillment.new(event_store: event_store, command_bus: command_bus),
    to: [
      Orders::OrderSubmitted,
      Payments::AuthorizationSucceeded,
      Payments::AuthorizationFailed,
      Orders::OrderCancelled,
      Orders::OrderShipped,
      Payments::CaptureSucceeded,
      Payments::CaptureFailed,
      Payments::VoidSucceeded,
      Payments::VoidFailed
    ]
  )

  event_store.subscribe(
    Payments::PaymentGatewaySwitcher.new(
      event_store:            event_store,
      command_bus:            command_bus,
      fallback_configuration: Rails.configuration.payment_gateway_fallback_configuration
    ),
    to: [
      Payments::AuthorizationSucceeded,
      Payments::CaptureSucceeded,
      Payments::VoidSucceeded,
      Payments::AuthorizationFailed,
      Payments::CaptureFailed,
      Payments::VoidFailed
    ]
  )

  # Payments commands.
  command_bus.register(Payments::AuthorizeCreditCard, Payments::OnAuthorizeCreditCard.new(event_store))
  command_bus.register(Payments::CaptureAuthorization, Payments::OnCaptureAuthorization.new(event_store))
  command_bus.register(Payments::VoidAuthorization, Payments::OnVoidAuthorization.new(event_store))
  command_bus.register(Payments::RefundPayment, Payments::OnRefundPayment.new(event_store))

  command_bus.register(Payments::RegisterPaymentGateway, Payments::OnRegisterPaymentGateway.new(event_store))
  command_bus.register(Payments::ChoosePrimaryPaymentGateway, Payments::OnChoosePrimaryPaymentGateway.new(event_store))
  command_bus.register(Payments::SwitchToFallbackPaymentGateway, Payments::OnSwitchToFallbackPaymentGateway.new(event_store))

  # Orders commands.
  command_bus.register(Orders::SubmitOrder, Orders::OnSubmitOrder.new(event_store))
  command_bus.register(Orders::ShipOrder, Orders::OnShipOrder.new(event_store))
  command_bus.register(Orders::CancelOrder, Orders::OnCancelOrder.new(event_store))
end
