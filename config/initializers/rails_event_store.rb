require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::Client.new
  Rails.configuration.command_bus = command_bus = Arkency::CommandBus.new

  AggregateRoot.configure do |config|
    config.default_event_store = event_store
  end

  # Payments commands.
  command_bus.register(Payments::AuthorizeCreditCard, Payments::OnAuthorizeCreditCard.new(event_store))
  command_bus.register(Payments::CaptureAuthorization, Payments::OnCaptureAuthorization.new(event_store))
  command_bus.register(Payments::VoidAuthorization, Payments::OnVoidAuthorization.new(event_store))

  # Orders commands.
  command_bus.register(Orders::SubmitOrder, Orders::OnSubmitOrder.new(event_store))
  command_bus.register(Orders::ShipOrder, Orders::OnShipOrder.new(event_store))
  command_bus.register(Orders::CancelOrder, Orders::OnCancelOrder.new(event_store))
end
