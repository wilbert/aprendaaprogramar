# frozen_string_literal: true

require_relative "boot"

require "rails"
# Load only the frameworks this app needs. It has no database, mailer, jobs,
# cable, or asset pipeline, so ActiveRecord/ActionMailer/etc. are left out.
require "action_controller/railtie"
require "action_view/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Aprendaaprogramar
  class Application < Rails::Application
    # Initialize configuration defaults for the originally generated Rails version.
    config.load_defaults 8.1

    # The tutorial engine under lib/ predates Zeitwerk naming conventions, so it
    # is required explicitly (see config/initializers/learn_to_program.rb) rather
    # than autoloaded. Keep lib out of the autoload/eager-load paths.
    config.autoload_lib(ignore: %w[learn_to_program_tutorial learn_to_program_tutorial.rb tasks assets])

    # This app renders full HTML documents produced by the tutorial engine and
    # serves its static CSS/images from public/. No time zone / i18n plumbing needed.
    config.time_zone = "UTC"

    # Host authorization: allow the configured host. Set APP_HOST in the
    # environment (see .env) to your real domain. When unset, host checks are
    # disabled so the app is reachable by IP or an arbitrary domain.
    if ENV["APP_HOST"].present?
      config.hosts << ENV["APP_HOST"]
      config.hosts << ".#{ENV['APP_HOST']}"
    else
      config.hosts.clear
    end
  end
end
