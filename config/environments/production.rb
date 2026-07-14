# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache in memory (no external cache store needed for this app).
  config.cache_store = :memory_store

  # Enable serving static files from public/ (nginx also serves them, but this
  # keeps the app self-sufficient if fronted differently).
  config.public_file_server.enabled = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Assume all access to the app is happening through an SSL-terminating reverse proxy (nginx).
  config.assume_ssl = true

  # Optionally force all access over SSL (nginx already redirects http->https).
  config.force_ssl = %w[true 1 yes on].include?(ENV.fetch("FORCE_SSL", "false").downcase)

  # Skip the http-to-https redirect for the health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT so systemd/journald captures output.
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.log_tags = [:request_id]

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Host authorization is configured in config/application.rb based on APP_HOST.
end
