#!/usr/bin/env nix-shell
#!nix-shell -p nixpkgs-fmt -i bash
nixpkgs-fmt "${1-.}"
