#!/bin/sh

GRAFANA_DASHBOARD="http://nuc:3000/d/-Jz7HnRMz/room-temperature-and-humidity?orgId=1&refresh=30s#"
GRAFANA_ROOM_HUMIDITY="http://nuc:3000/render/d-solo/-Jz7HnRMz/room-temperature-and-humidity?orgId=1&refresh=30s&panelId=20&width=1000&height=500&tz=Europe%2FZurich"

nats req ntfy.http <<EDN
 {:headers {:title  "Grafana"
            :click  "$GRAFANA_DASHBOARD"
            :attach "$GRAFANA_ROOM_HUMIDITY"}
  :body "Room humidity for the past 24 hours"}
EDN
