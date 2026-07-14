# frozen_string_literal: true

# Puma configuration for the "Aprenda a Programar" tutorial app.
#
# In development it listens on a TCP port; in production it binds a unix socket
# that nginx proxies to (see deploy/nginx/aprendaaprogramar), matching the mio setup.

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

rails_env = ENV.fetch("RAILS_ENV", "development")
environment rails_env

pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

if rails_env == "production"
  app_dir = File.expand_path("..", __dir__)
  socket = ENV.fetch("PUMA_SOCKET", File.join(app_dir, "tmp", "sockets", "puma.sock"))
  bind "unix://#{socket}"

  # Run a few worker processes. The tutorial engine mutates process-global state
  # while executing sample code and is serialized per-process by a mutex in the
  # controller, so multiple worker processes give real parallelism safely.
  workers ENV.fetch("WEB_CONCURRENCY", 2).to_i
  preload_app!
else
  port ENV.fetch("PORT", 4050)
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
