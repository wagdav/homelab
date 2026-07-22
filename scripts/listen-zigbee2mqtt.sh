#!/bin/sh

nix shell nixpkgs#mosquitto --command mosquitto_sub -h nats -p 1883 -t 'zigbee2mqtt/#' -v
