# frozen_string_literal: true

require "capistrano/setup"
require "capistrano/deploy"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require "capistrano/rbenv"
require "capistrano/bundler"

# This app has no database and no asset pipeline, so capistrano-rails' migrations
# and assets tasks are intentionally not loaded.

# Custom tasks (systemd restart).
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
