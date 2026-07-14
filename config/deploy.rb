# frozen_string_literal: true

# Capistrano deploy for "Aprenda a Programar" (Rails 8) onto the same VPS as mio
# (no Docker). Puma runs as a systemd service; nginx fronts Puma's unix socket.
lock "~> 3.19"

set :application, "aprendaaprogramar"
set :repo_url, "git@github.com:wilbert/aprendaaprogramar.git"
set :branch, ENV.fetch("BRANCH", "main")

set :deploy_to, "/var/www/aprendaaprogramar"

# Ruby via system-wide rbenv on the server (/usr/local/rbenv), matching mio.
set :rbenv_type, :system
set :rbenv_ruby, File.read(".ruby-version").strip

# Shared (symlinked) config and persistent dirs.
append :linked_files, ".env"
append :linked_dirs,
       "log",
       "tmp/pids",
       "tmp/cache",
       "tmp/sockets"

set :keep_releases, 5
set :bundle_jobs, 4
set :bundle_flags, "--quiet"

# The app has no database and no asset pipeline, so bundle without dev/test only.
set :bundle_without, "development test"
