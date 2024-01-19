#!/bin/sh

nix shell nixpkgs#prometheus-alertmanager --command amtool \
    --alertmanager.url http://nuc:9093 \
    alert add \
    --annotation=summary="Test alert" \
    --annotation=description="This is a test alert sent from $(hostname) by $USER" \
    instance="$(hostname)"
