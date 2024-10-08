#!/usr/bin/env bash
set -eo pipefail

if [ "$1" = "create-network-connections" ]; then
    nmcli connection delete id openwrt-repeater || true

    nmcli connection add \
        type ethernet \
        con-name openwrt-repeater \
        autoconnect false \
        ipv4.ignore-auto-routes yes \
        ipv4.ignore-auto-dns yes \
        ip4 192.168.2.2/24

    exit 0
fi

if [ "$1" = "first-time" ]; then
    SSH_COMMAND="ssh root@192.168.1.1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    FIRST_TIME=true
else
    SSH_COMMAND="ssh root@192.168.2.1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
    FIRST_TIME=false
fi

HERE=$(dirname "$(readlink -f "$0")")
$SSH_COMMAND sh -s \
    "$(printf "%q" $FIRST_TIME)" \
    "$(printf "%q" "$(pass Home/wifi_ssid)")" \
    "$(printf "%q" "$(pass Home/wifi_key)")" \
    < "$HERE"/config-repeater
