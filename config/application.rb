require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Require custom middleware
require_relative "../lib/middleware/metrics_middleware"

module BmsOps
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    # Configure structured JSON logging
    config.log_formatter = proc do |severity, timestamp, progname, msg|
      log_entry = {
        timestamp: timestamp.iso8601,
        level: severity.downcase,
        message: msg.is_a?(String) ? msg : msg.inspect,
        progname: progname
      }
      "#{log_entry.to_json}\n"
    end

    # Add metrics middleware for HTTP request timing
    config.middleware.use MetricsMiddleware
  end
end
