require 'rails_event_store'
require 'aggregate_root'
require 'arkency/command_bus'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::Client.new
  Rails.configuration.command_bus = command_bus = Arkency::CommandBus.new

  AggregateRoot.configure do |config|
    config.default_event_store = event_store
  end
end
