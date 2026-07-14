#!/usr/bin/env bash

# Server-side deploy for aprendaaprogramar.
#
# This script is invoked by GitHub Actions over SSH and is safe to run by hand:
#
#   APP_DIR=/var/www/aprendaaprogramar ./scripts/deploy.sh
#
# It updates the repository from origin/main and restarts the systemd service.

{
  set -euo pipefail

  APP_DIR="${APP_DIR:-/var/www/aprendaaprogramar}"
  cd "$APP_DIR"

  echo "==> Fetching latest main"
  git fetch --depth 1 origin main
  git reset --hard origin/main

  if [ -f Gemfile ]; then
    echo "==> Installing bundle dependencies"
    bundle install --without development test
  else
    echo "==> No Gemfile found; skipping bundle install"
  fi

  echo "==> Restarting aprendaaprogramar service"
  sudo systemctl restart aprendaaprogramar.service

  echo "==> Deploy complete"
  exit 0
}
