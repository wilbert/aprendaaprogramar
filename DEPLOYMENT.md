# Deployment

Auto-deploy to a Contabo VPS using GitHub Actions. Pushing to `main` triggers a deploy workflow that SSHes into the VPS and runs the server-side deploy script.

## How it works

```
git push origin main
      │
      ▼
GitHub Actions (.github/workflows/deploy.yml)
      │  SSH (key in GitHub secret VPS_SSH_KEY)
      ▼
VPS: scripts/deploy.sh
      │  git reset --hard origin/main
      │  [bundle install]
      │  systemctl restart aprendaaprogramar.service
      ▼
Rails app runs on localhost:3000
      │
      ▼
nginx reverse-proxies HTTPS traffic to 127.0.0.1:3000
```

This repository includes:

- `.github/workflows/deploy.yml` — GitHub Actions deploy workflow
- `scripts/deploy.sh` — server-side deploy script run on the VPS
- `deploy/nginx-aprendaaprogramar.conf` — nginx proxy config template
- `deploy/aprendaaprogramar.service` — example systemd service

## One-time VPS setup

These commands should be run on the Contabo VPS. Start as `root` or a sudo user.

### 1. Create the deploy user

```bash
adduser deploy
usermod -aG sudo deploy
```

Switch to the deploy user for the rest of the setup:

```bash
su - deploy
```

### 2. Install Ruby and Rails

This is a legacy Rails 2 application, so the server must have a compatible Ruby installation.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git build-essential curl nginx ruby ruby-dev rubygems
sudo gem install rails -v 2.0.5
```

If your distribution does not provide a compatible Ruby version, use a version manager such as `rbenv` or a suitable legacy package source.

### 3. Configure SSH access for the repo

Generate a deploy key for the app on the VPS:

```bash
ssh-keygen -t ed25519 -C "aprendaaprogramar-vps-deploy-key" -f ~/.ssh/github_aprendaaprogramar -N ""
cat ~/.ssh/github_aprendaaprogramar.pub
```

Add the public key to the GitHub repository as a read-only deploy key.

Then set up the host alias in `~/.ssh/config`:

```text
Host github-aprendaaprogramar
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_aprendaaprogramar
  IdentitiesOnly yes
```

Verify access:

```bash
ssh -T git@github-aprendaaprogramar
```

### 4. Clone the repository

```bash
sudo mkdir -p /var/www
sudo chown deploy:deploy /var/www
cd /var/www
git clone git@github-aprendaaprogramar:wilbert/aprendaaprogramar.git
cd aprendaaprogramar
```

### 5. Install systemd service

Copy the example service file to `/etc/systemd/system/aprendaaprogramar.service`:

```bash
sudo cp deploy/aprendaaprogramar.service /etc/systemd/system/aprendaaprogramar.service
sudo systemctl daemon-reload
sudo systemctl enable aprendaaprogramar.service
sudo systemctl start aprendaaprogramar.service
```

Confirm it is running:

```bash
sudo systemctl status aprendaaprogramar.service
```

### 6. Configure nginx

Copy and enable the nginx server block:

```bash
sudo cp deploy/nginx-aprendaaprogramar.conf /etc/nginx/sites-available/aprendaaprogramar
sudo ln -s /etc/nginx/sites-available/aprendaaprogramar /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

Replace `APP_DOMAIN` in the copied nginx config with your actual domain name, and obtain TLS certificates with Certbot if needed.

### 7. Add GitHub Actions secrets

In GitHub repository settings → Secrets and variables → Actions, add the following secrets:

| Secret | Value |
|---|---|
| `VPS_HOST` | VPS IP or hostname |
| `VPS_USER` | `deploy` |
| `VPS_SSH_KEY` | private SSH key for GitHub Actions to log into the VPS |
| `VPS_SSH_PORT` | SSH port (optional; leave unset for `22`) |
| `APP_DIR` | `/var/www/aprendaaprogramar` |

The workflow will use the deploy user to SSH into the VPS and run `scripts/deploy.sh`.

## Deploying

- Push to `main` to trigger the deploy workflow automatically.
- Or run the workflow manually from GitHub Actions.
- To deploy from the VPS by hand:

```bash
cd /var/www/aprendaaprogramar
APP_DIR=$PWD bash scripts/deploy.sh
```

## Troubleshooting

- If `git ls-remote origin main` fails on the server, verify the SSH deploy key and the `github-aprendaaprogramar` alias.
- If `systemctl restart aprendaaprogramar.service` fails, inspect the unit with `sudo journalctl -u aprendaaprogramar.service -b`.
- If nginx proxying fails, check `sudo nginx -t` and reload nginx again.
