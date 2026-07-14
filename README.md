# Aprenda a Programar

Aprenda a Programar is a small Ruby on Rails application that serves an interactive programming tutorial. The project is based on an older Rails codebase and is designed to render the tutorial content from the library under the `lib/learn_to_program_tutorial` directory.

## Project overview

This repository contains:

- a Rails 2-style application entry point
- a controller that handles tutorial requests
- a set of tutorial modules and helpers under `lib/learn_to_program_tutorial`
- a lightweight routing setup for the main tutorial page

The app does not rely on Active Record or a traditional database setup, so local development is straightforward.

## Requirements

Because this project uses an older Rails version, you should use a compatible Ruby environment.

Recommended:

- Ruby 1.9.x or Ruby 2.0.x
- RubyGems
- Git
- A Unix-based environment (Linux/macOS)

> This project is a legacy Rails application. If you run into gem compatibility issues, the most likely cause is an unsupported Ruby/Rails combination.

## Local setup

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd aprendaaprogramar
   ```

2. Install Ruby and RubyGems if they are not already available.

3. Install the Rails version expected by the project:

   ```bash
   gem install rails -v 2.0.5
   ```

4. Install any required dependencies for the environment. This project does not use a modern `Gemfile`, so you may need to install gems manually if the app reports missing libraries at runtime.

5. Start the application:

   ```bash
   ruby script/server -p 4050
   ```

6. Open the app in your browser:

   ```text
   http://localhost:4050
   ```

## Deployment

This project includes a GitHub Actions deploy workflow and server-side deploy script for Contabo VPS deployment.

- `DEPLOYMENT.md` contains the full deploy process.
- `.github/workflows/deploy.yml` is the GitHub Actions workflow that SSHes into the VPS and runs `scripts/deploy.sh`.
- `scripts/deploy.sh` updates the repo and restarts the systemd service.
- `deploy/nginx-aprendaaprogramar.conf` is a template for nginx reverse proxy configuration.
- `deploy/aprendaaprogramar.service` is an example systemd unit file.

See `DEPLOYMENT.md` for the recommended Contabo setup, deploy key configuration, and workflow secrets.

## Production deployment on a Contabo VPS

The following steps assume a Ubuntu-based Contabo VPS.

### 1. Prepare the server

Connect to your VPS and update the system:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git build-essential curl nginx ruby ruby-dev
```

If needed, install RubyGems:

```bash
sudo apt install -y rubygems
```

### 2. Install Rails and required gems

Install the legacy Rails version used by the app:

```bash
sudo gem install rails -v 2.0.5
```

If the app needs additional gems during startup, install them one by one as errors appear.

### 3. Clone the application

```bash
cd /var/www
sudo git clone <repository-url> aprendaaprogramar
cd aprendaaprogramar
```

### 4. Configure the environment

Set the application to production mode:

```bash
export RAILS_ENV=production
```

You may also want to create a production-ready shell script or service file if you plan to run the app continuously.

### 5. Run the app

For a simple deployment, start the app directly:

```bash
ruby script/server -e production -p 4050
```

If you want the app to stay running in the background, use a process manager such as `screen` or `tmux`.

### 6. Use Nginx as a reverse proxy

A typical Nginx configuration can forward traffic to the Rails app on port 4050.

Example configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:4050;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Save it to `/etc/nginx/sites-available/aprendaaprogramar` and enable it:

```bash
sudo ln -s /etc/nginx/sites-available/aprendaaprogramar /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 7. Optional: use a service manager

For better reliability, you can create a systemd service so the app starts automatically after reboot.

Example service file:

```bash
sudo nano /etc/systemd/system/aprendaaprogramar.service
```

```ini
[Unit]
Description=Aprenda a Programar Rails App
After=network.target

[Service]
WorkingDirectory=/var/www/aprendaaprogramar
Environment=RAILS_ENV=production
ExecStart=/usr/bin/ruby /var/www/aprendaaprogramar/script/server -e production -p 4050
Restart=always
User=www-data
Group=www-data

[Install]
WantedBy=multi-user.target
```

Then enable it:

```bash
sudo systemctl daemon-reload
sudo systemctl enable aprendaaprogramar
sudo systemctl start aprendaaprogramar
```

## Notes

- This project is not configured for a modern database-backed Rails setup.
- The application is intentionally lightweight and serves content directly through the tutorial library.
- If you plan to deploy it long-term, consider modernizing the Rails stack to a current supported version.

## Useful commands

```bash
ruby script/server -p 4050
ruby script/console
```
