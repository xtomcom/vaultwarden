#!/bin/sh
set -e

# Only stop on removal (deb: $1=remove, rpm: $1=0); upgrades restart in postinstall
case "$1" in
    remove|0)
        if [ -d /run/systemd/system ]; then
            systemctl disable --now vaultwarden.service >/dev/null || true
        fi
        ;;
esac
