# Deployment

Production runs on the same Contabo VPS as the `mio` project, deployed with
**Capistrano** from your machine. Puma runs as a systemd service and nginx fronts
Puma's unix socket.

```
bundle exec cap production deploy
        │  ssh deploy@13.140.144.154 (key: ~/.ssh/mio_contabo_deploy, agent-forwarded)
        ▼
/var/www/aprendaaprogramar/releases/<timestamp>   git checkout + bundle install
        │  symlink current -> release, link shared/.env
        ▼
deploy:restart  ->  sudo systemctl restart aprendaaprogramar-puma
        │
        ▼
Puma listens on shared/tmp/sockets/puma.sock
        │
        ▼
nginx (HTTPS) reverse-proxies to the Puma socket
```

## What's in the repo

- [`Capfile`](Capfile), [`config/deploy.rb`](config/deploy.rb),
  [`config/deploy/production.rb`](config/deploy/production.rb) — Capistrano config
- [`lib/capistrano/tasks/systemd.rake`](lib/capistrano/tasks/systemd.rake) —
  `deploy:restart` / `deploy:status` via systemd
- [`deploy/systemd/aprendaaprogramar-puma.service`](deploy/systemd/aprendaaprogramar-puma.service) — the Puma unit
- [`deploy/nginx/aprendaaprogramar`](deploy/nginx/aprendaaprogramar) — nginx server block (replace `APP_DOMAIN`)
- [`deploy/sudoers/aprendaaprogramar-deploy`](deploy/sudoers/aprendaaprogramar-deploy) — lets the deploy user restart the service without a password
- [`.env.example`](.env.example) — the env vars that go in `shared/.env`

## One-time VPS setup

Run on the VPS as a sudo-capable user. rbenv is already installed system-wide at
`/usr/local/rbenv` (shared with the `mio` app).

### 1. Ruby 3.4.4

```bash
sudo /usr/local/rbenv/bin/rbenv install -s 3.4.4
sudo /usr/local/rbenv/shims/gem install bundler
```

### 2. App directories and shared config

```bash
sudo mkdir -p /var/www/aprendaaprogramar/shared/tmp/sockets
sudo chown -R deploy:deploy /var/www/aprendaaprogramar

# Create shared/.env from the template and fill it in (SECRET_KEY_BASE, APP_HOST…).
# Generate a real secret with: bin/rails secret
```

`shared/.env` (see [.env.example](.env.example)) at minimum:

```
SECRET_KEY_BASE=<output of `bin/rails secret`>
APP_HOST=APP_DOMAIN
WEB_CONCURRENCY=2
```

### 3. systemd service

```bash
sudo cp deploy/systemd/aprendaaprogramar-puma.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable aprendaaprogramar-puma
# (started/restarted automatically by Capistrano's deploy:restart)
```

### 4. Passwordless restart for the deploy user

```bash
sudo cp deploy/sudoers/aprendaaprogramar-deploy /etc/sudoers.d/aprendaaprogramar-deploy
sudo chmod 0440 /etc/sudoers.d/aprendaaprogramar-deploy
sudo visudo -c
```

### 5. nginx + TLS

Edit `deploy/nginx/aprendaaprogramar`, replace `APP_DOMAIN` with your real domain, then:

```bash
sudo cp deploy/nginx/aprendaaprogramar /etc/nginx/sites-available/aprendaaprogramar
sudo ln -s /etc/nginx/sites-available/aprendaaprogramar /etc/nginx/sites-enabled/
sudo certbot --nginx -d APP_DOMAIN -d www.APP_DOMAIN
sudo nginx -t && sudo systemctl reload nginx
```

### 6. GitHub access for the server

Capistrano fetches the repo from GitHub over SSH using **agent forwarding**
(`forward_agent: true` in `config/deploy/production.rb`), so the server uses *your*
SSH key. Make sure your key is loaded locally (`ssh-add -l`) and has access to
`git@github.com:wilbert/aprendaaprogramar.git`.

## Deploying

```bash
# Ensure your VPS deploy key and GitHub key are available to the ssh agent:
ssh-add ~/.ssh/mio_contabo_deploy    # VPS login key (or set DEPLOY_SSH_KEY)

bundle exec cap production deploy         # deploy the `main` branch
BRANCH=some-branch bundle exec cap production deploy
bundle exec cap production deploy:status  # systemctl status of the Puma service
```

Overridable env vars:

| Var | Default | Purpose |
|---|---|---|
| `BRANCH` | `main` | branch to deploy |
| `DEPLOY_SSH_KEY` | `~/.ssh/mio_contabo_deploy` | key used to log into the VPS |

## Troubleshooting

- **Puma won't start:** `sudo journalctl -u aprendaaprogramar-puma -b`. Most often a
  missing/invalid `SECRET_KEY_BASE` in `shared/.env`.
- **nginx 502:** confirm the socket exists at
  `/var/www/aprendaaprogramar/shared/tmp/sockets/puma.sock` and that the service is
  running.
- **`Blocked host` / 403:** set `APP_HOST` in `shared/.env` to your domain (see
  [config/application.rb](config/application.rb)).
- **GitHub fetch fails on the server:** run `ssh-add -l` locally; agent forwarding
  needs your GitHub key loaded before `cap deploy`.
