# Forgejo Deploy

Automated Forgejo and MySQL/MariaDB deployment script for Debian.

Official project: https://forgejo.org/

## Features

* Installs Forgejo from the official binary release
* Installs and configures MySQL/MariaDB
* Creates the Forgejo database and user
* Creates the required system user and directories
* Configures and enables the systemd service
* Starts Forgejo automatically after installation

## Requirements

* Debian 11/12/13
* Root access
* Internet connection

## Installation

Clone the repository:

```bash
git clone https://github.com/Neur0z/forgejo-deploy.git
cd forgejo-deploy
```

Make the script executable:

```bash
chmod +x install.sh
```

Run the installation:

```bash
./install.sh
```

Or:

```bash
bash install.sh
```

## What gets installed

* Git
* Git LFS
* MariaDB/MySQL
* Forgejo
* systemd service

## Accessing Forgejo

After installation, open:

```text
http://SERVER_IP:3000
```

Complete the initial Forgejo setup in the web interface.

## Directory Layout

```text
/etc/forgejo
/var/lib/forgejo
/home/git
```

## Service Management

Check status:

```bash
systemctl status forgejo
```

Restart:

```bash
systemctl restart forgejo
```

View logs:

```bash
journalctl -u forgejo -f
```

## Updating Forgejo

This repository currently focuses on deployment only.

Forgejo updates should be performed manually.

## Tested On

* Debian 13 (Trixie)
* Debian 12 (Bookworm)

## Disclaimer

Use at your own risk.

Always test in a non-production environment before deploying to production servers.