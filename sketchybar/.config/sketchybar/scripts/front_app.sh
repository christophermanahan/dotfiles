#!/bin/sh

source "$CONFIG_DIR/icon_map_fn.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  icon=$(icon_map "$INFO")
  sketchybar --set "$NAME" label="$icon $INFO"
fi
