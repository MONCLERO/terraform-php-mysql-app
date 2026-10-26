#!/bin/bash
# This tier faces the internet, servers static pages, forward dynamic requests onward

set -e
export DEBIAN_FRONTEND=noninteractive

echo "== Web tier setup started: $(date) =="

# ------ APT CONFIG ------ #
sudo apt-get update
sudo apt-get install apache2 -y
sudo systemctl enable apache2
echo "Env configuration complete!" | sudo tee -a /var/log/setup.log

# ----- PORTS SETUP ------ #

sudo a2enmod proxy proxy_http  # enable module proxy - forward request using http

cat > /etc/apache2/sites-available/proxy.conf <<'EOF'
<VirtualHost *:80>
    ProxyPreserveHost On
    ProxyPass / http://${app_host}:8080/
    ProxyPassReverse / http://${app_host}:8080/
</VirtualHost>
EOF

a2dissite 000-default
a2ensite proxy

# ----- VALIDATION & RESTART ----- #

sudo apache2ctl configtest 
sudo systemctl reload apache2

echo "== Web tier setup completed: $(date) =="
