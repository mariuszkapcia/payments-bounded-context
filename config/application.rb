require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PaymentsBoundedContext
  class Application < Rails::Application
    config.load_defaults 5.2

    config.paths.add 'lib/',         eager_load: true
    config.paths.add 'command/lib',  eager_load: true
    config.paths.add 'payments/lib', eager_load: true
    config.paths.add 'orders/lib',   eager_load: true
    config.paths.add 'ui/lib',       eager_load: true
  end
end
