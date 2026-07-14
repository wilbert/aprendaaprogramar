# frozen_string_literal: true

# Puma configuration for the "Aprenda a Programar" tutorial app.
#
# nginx on the VPS reverse-proxies to Puma on TCP port 4050 (127.0.0.1 and [::1]),
# so Puma binds both loopback stacks in production. Override with PORT if needed.

max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

rails_env = ENV.fetch("RAILS_ENV", "development")
environment rails_env

pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

port_number = ENV.fetch("PORT", 4050)

if rails_env == "production"
  # Listen on both IPv4 and IPv6 loopback so nginx reaches Puma whether it
  # proxies to 127.0.0.1:4050, [::1]:4050, or localhost:4050.
  bind "tcp://127.0.0.1:#{port_number}"
  bind "tcp://[::1]:#{port_number}"

  # Run a few worker processes. The tutorial engine mutates process-global state
  # while executing sample code and is serialized per-process by a mutex in the
  # controller, so multiple worker processes give real parallelism safely.
  workers ENV.fetch("WEB_CONCURRENCY", 2).to_i
  preload_app!
else
  port port_number
end

# Allow puma to be restarted by `bin/rails restart` command.
plugin :tmp_restart
