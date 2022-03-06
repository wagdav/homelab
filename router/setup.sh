#!/bin/sh
set -e

if [ "$1" = "--first-time" ]; then
    SSH_COMMAND="ssh root@192.168.1.1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
else
    SSH_COMMAND="ssh root@wrt"
fi

HERE=$(dirname "$(readlink -f "$0")")
$SSH_COMMAND sh -s \
    "$(printf "%q" "$(pass Home/wifi_ssid)")" \
    "$(printf "%q" "$(pass Home/wifi_key)")" \
    < "$HERE"/config
