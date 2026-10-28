#!/bin/sh
set -e

# deb: $1=configure, $2=previous version (empty on fresh install)
# rpm: $1=number of installed instances (1 on fresh install)
fresh_install=false
case "$1" in
    configure) [ -z "$2" ] && fresh_install=true ;;
    1) fresh_install=true ;;
esac

if ! getent group vaultwarden >/dev/null; then
    groupadd --system vaultwarden
fi
if ! getent passwd vaultwarden >/dev/null; then
    useradd --system --gid vaultwarden --home-dir /var/lib/vaultwarden \
        --no-create-home --shell /usr/sbin/nologin vaultwarden
fi

chown vaultwarden:vaultwarden /var/lib/vaultwarden
chmod 0700 /var/lib/vaultwarden
chown root:vaultwarden /etc/vaultwarden/vaultwarden.env
chmod 0640 /etc/vaultwarden/vaultwarden.env

if [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null || true
    if [ "${fresh_install}" = "true" ]; then
        systemctl enable --now vaultwarden.service >/dev/null || true
    else
        systemctl try-restart vaultwarden.service >/dev/null || true
    fi
fi
