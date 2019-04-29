#!/bin/bash

if [[ -f vault_consul.conf ]]; then
  read -r -p "config file vault_consul.conf exists and will be overwritten, are you sure you want to contine? [y/N] " response
  case $response in
    [yY][eE][sS]|[yY])
      mv vault_consul.conf vault_consul.conf_backup
      ;;
    *)
      exit 1
    ;;
  esac
fi

if [ -z "$VAULT_PUBLIC_FQDN" ]; then
  read -p "Vault Hostname (FQDN): " -ei "vault.example.org" VAULT_PUBLIC_FQDN
fi

if [ -z "$CONSUL_PUBLIC_FQDN" ]; then
  read -p "Consul Hostname (FQDN): " -ei "consul.example.org" CONSUL_PUBLIC_FQDN
fi

if [ -z "$ADMIN_MAIL" ]; then
  read -p "Vault admin Mail address: " -ei "mail@example.com" ADMIN_MAIL
fi

[[ -f /etc/timezone ]] && TZ=$(cat /etc/timezone)
if [ -z "$TZ" ]; then
  read -p "Timezone: " -ei "Europe/Berlin" TZ
fi

DBPASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)

VAULT_HTTP_PORT=8200
CONSUL_HTTP_PORT=8500

cat << EOF > vault_consul.conf
# ------------------------------
# vault web ui configuration
# ------------------------------
# example.org is _not_ a valid hostname, use a fqdn here.
VAULT_PUBLIC_FQDN=${VAULT_PUBLIC_FQDN}
CONSUL_PUBLIC_FQDN=${CONSUL_PUBLIC_FQDN}

# ------------------------------
# VAULT admin user
# ------------------------------
VAULT_ADMIN=vaultadmin
ADMIN_MAIL=${ADMIN_MAIL}
VAULT_PASS=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
# ------------------------------
# SQL database configuration
# ------------------------------
DBNAME=${DBNAME}
DBUSER=${DBUSER}
# Please use long, random alphanumeric strings (A-Za-z0-9)
DBPASS=${DBPASS}
DBROOT=$(</dev/urandom tr -dc A-Za-z0-9 | head -c 28)
# ------------------------------
# Bindings
# ------------------------------
# You should use HTTPS, but in case of SSL offloaded reverse proxies:
VAULT_HTTP_PORT=${VAULT_HTTP_PORT}
VAULT_HTTP_BIND=0.0.0.0
CONSUL_HTTP_PORT=${VAULT_HTTP_PORT}
CONSUL_VAULT_HTTP_BIND=0.0.0.0

# Your timezone
TZ=${TZ}
# Fixed project name
#COMPOSE_PROJECT_NAME=vault
EOF
