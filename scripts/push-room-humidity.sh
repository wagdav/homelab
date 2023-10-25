#!/bin/sh

NTFY_ADDRESS=http://nuc:8080/home-thewagner-ec1
GRAFANA_DASHBOARD="http://nuc:3000/d/-Jz7HnRMz/room-temperature-and-humidity?orgId=1&refresh=30s#"
GRAFANA_ROOM_HUMIDITY="http://nuc:3000/render/d-solo/-Jz7HnRMz/room-temperature-and-humidity?orgId=1&refresh=30s&panelId=20&width=1000&height=500&tz=Europe%2FZurich"

curl \
  -H "Title: Grafana" \
  -H "Click: $GRAFANA_DASHBOARD" \
  -H "Attach: $GRAFANA_ROOM_HUMIDITY" \
  -d "Room humidity for the past 24 hours" \
  "$NTFY_ADDRESS"
