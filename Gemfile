# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.4.4"

gem "rails", "~> 8.1.1"
gem "puma", "~> 8.0"

# This app serves a self-contained Ruby tutorial engine (lib/learn_to_program_tutorial).
# It has no database and no asset pipeline, so ActiveRecord / Propshaft are intentionally absent.

# The legacy tutorial engine is written against Ruby's CGI class; keep the gem available
# (cgi is being demoted from Ruby's default gems).
gem "cgi"

# stdlib gems that Ruby 3.4 no longer ships as defaults but Rails/engine still use.
gem "bootsnap", require: false
gem "logger"
gem "ostruct"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
end

group :development do
  # Capistrano deployment (mirrors the mio project's setup).
  gem "capistrano", "~> 3.19", require: false
  gem "capistrano-rails", "~> 1.7", require: false
  gem "capistrano-bundler", "~> 2.1", require: false
  gem "capistrano-rbenv", "~> 2.2", require: false

  # net-ssh ed25519 key support (used by Capistrano).
  gem "ed25519", "~> 1.2", require: false
  gem "bcrypt_pbkdf", "~> 1.0", require: false
end
