#!/bin/sh
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 HOST" >&2
  exit 1
fi

host="$1"

if [ "$host" = "$(hostname)" ]; then
    sudo nixos-rebuild switch \
        --flake ".#$host"
else
    nix run 'nixpkgs#nixos-rebuild' -- switch \
        --flake ".#$host" \
        --target-host "root@$host" \
        --build-host  "root@$host" \
        --no-reexec
fi
