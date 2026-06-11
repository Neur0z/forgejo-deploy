#!/bin/bash
apt update && apt install -y curl wget git git-lfs

# Install MySQL if not installed
if ! which mysql | grep -q "bin"; then
  apt install -y default-mysql-server
fi

# Prepare database and user
dbname=forgejo
dbuser=forgejo
dbpasswd=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c14)

mysql << EOF
CREATE DATABASE IF NOT EXISTS $dbname;
CREATE USER IF NOT EXISTS '$dbuser'@'localhost' IDENTIFIED BY '$dbpasswd';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';
FLUSH PRIVILEGES;
EOF

# Download latest release Forgejo
ver=$(curl -sI https://codeberg.org/forgejo/forgejo/releases/latest | grep -i "location.*tag" | rev | cut -d'/' -f 1 | rev | tr -d '\r|v')
wget -O /usr/local/bin/forgejo "https://codeberg.org/forgejo/forgejo/releases/download/v$ver/forgejo-$ver-linux-amd64" && \
  chmod +x /usr/local/bin/forgejo

# Create Git user
if ! grep -iq "^git:" /etc/passwd; then
  adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
fi

# Prepare dirs
if [ ! -d /var/lib/forgejo ]; then
  mkdir /var/lib/forgejo
  chown git:git /var/lib/forgejo && chmod 750 /var/lib/forgejo
fi

if [ ! -d /etc/forgejo ]; then
  mkdir /etc/forgejo
  chown root:git /etc/forgejo && chmod 770 /etc/forgejo
fi

# Add 'forgejo' service
wget -O /etc/systemd/system/forgejo.service https://codeberg.org/forgejo/forgejo/raw/branch/forgejo/contrib/systemd/forgejo.service

if [ -f /lib/systemd/system/mariadb.service ]; then
  sed -i 's/#Wants=mariadb/Wants=mariadb/g' /etc/systemd/system/forgejo.service
  sed -i 's/#After=mariadb/Wants=mariadb/g' /etc/systemd/system/forgejo.service
fi

# Fix 'memcached' service if exists
if [ -f /lib/systemd/system/memcached.service ]; then
  sed -i 's/#Wants=memcached/Wants=memcached/g' /etc/systemd/system/forgejo.service
  sed -i 's/#After=memcached/After=memcached/g' /etc/systemd/system/forgejo.service
fi

# Fix 'redis' service if exists
if [ -f /lib/systemd/system/redis-server.service ]; then
  sed -i 's/#Wants=redis/Wants=redis/g' /etc/systemd/system/forgejo.service
  sed -i 's/#After=redis/After=redis/g' /etc/systemd/system/forgejo.service
fi

systemctl daemon-reload && systemctl enable --now forgejo.service

# Print info
echo -e "DB name: $dbname"
echo -e "DB user: $dbuser"
echo -e "DB passwd: $dbpasswd"
echo -e "Complete the installation on URL: http://$(curl -s ifconfig.me 2> /dev/null):3000"