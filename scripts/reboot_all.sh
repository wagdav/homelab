#!/bin/sh
set -e

wait_for_consul() {
    echo "Waiting for the Consul agent to re-connect"
    sleep 30
}


nixops reboot --include ipc
wait_for_consul
nixops reboot --include nuc
wait_for_consul
nixops reboot --include rp3
