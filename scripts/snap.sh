#!/usr/bin/env nix
#! nix shell nixpkgs#natscli --command bash
# shellcheck shell=bash

nats request rpicam "" --timeout 10s
