# frozen_string_literal: true

# Same VPS the mio project deploys to.
server "13.140.144.154",
       user: "deploy",
       roles: %w[app web]

set :ssh_options, {
  keys: [File.expand_path(ENV.fetch("DEPLOY_SSH_KEY", "~/.ssh/mio_contabo_deploy"))],
  forward_agent: true,        # forward the local agent so the server can fetch from GitHub
  auth_methods: %w[publickey]
}
