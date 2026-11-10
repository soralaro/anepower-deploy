#!/bin/bash
# One-time install of the anepower.net site on lumayard. Run with: sudo bash ~/anepower-deploy/install.sh
set -euo pipefail
D="$(cd "$(dirname "$0")" && pwd)"
[ "$(id -u)" = 0 ] || { echo "Please run with sudo"; exit 1; }

install -d -o www-data -g www-data /var/www/anepower /var/www/anepower/fonts /var/www/acme
install -m 644 -o www-data -g www-data "$D/site/index.html" /var/www/anepower/
install -m 644 -o www-data -g www-data "$D"/site/fonts/*.woff2 /var/www/anepower/fonts/

install -d -m 700 /etc/nginx/ssl/anepower
install -m 644 "$D/ssl/fullchain.pem" /etc/nginx/ssl/anepower/fullchain.pem
install -m 600 "$D/ssl/key.pem"       /etc/nginx/ssl/anepower/key.pem

install -m 644 "$D/anepower.nginx" /etc/nginx/sites-available/anepower
ln -sf /etc/nginx/sites-available/anepower /etc/nginx/sites-enabled/anepower

if nginx -t; then
  systemctl reload nginx
  shred -u "$D/ssl/key.pem" 2>/dev/null || rm -f "$D/ssl/key.pem"
  echo "OK: anepower site installed and nginx reloaded."
else
  rm -f /etc/nginx/sites-enabled/anepower
  echo "nginx config test FAILED; anepower site disabled again, nothing else changed."; exit 1
fi
