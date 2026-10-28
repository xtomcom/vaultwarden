#!/bin/sh
set -e

if [ -d /run/systemd/system ]; then
    systemctl daemon-reload >/dev/null || true
fi

# Data in /var/lib/vaultwarden and the vaultwarden user are kept on purge on purpose
