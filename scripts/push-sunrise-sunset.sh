#!/bin/sh

LAT="46.519833N"
LON="6.6335E"

now=$(sunwait poll $LAT $LON)

if [ "$now" = "NIGHT" ]; then
  echo "Waiting for sunrise"
  HEADER="Sunrise!"
  MESSAGE="Good morning! 🌅"
else
  echo "Waiting for sunset"
  HEADER="Sunset!"
  MESSAGE="Good evening! 🌇"
fi

sunwait wait $LAT $LON

nats req ntfy.http <<EDN
 {:headers {:title "$HEADER"}
  :body "$MESSAGE"}
EDN
