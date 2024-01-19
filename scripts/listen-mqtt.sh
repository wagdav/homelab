#!/bin/sh

nix shell nixpkgs#mosquitto --command mosquitto_sub -h nuc -p 1883 -t '#' -v
