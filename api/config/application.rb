require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    config.action_dispatch.default_headers.merge!(
      "X-Frame-Options" => "DENY",
      "X-Content-Type-Options" => "nosniff",
      "Referrer-Policy" => "strict-origin-when-cross-origin",
      "Permissions-Policy" => "geolocation=(), camera=(), microphone=()"
    )
  end
end
