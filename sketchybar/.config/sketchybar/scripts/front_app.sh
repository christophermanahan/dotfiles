#!/bin/sh

source "$CONFIG_DIR/hash_color_fn.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  color=$(hash_color "$INFO")
  sketchybar --set "$NAME" label="$INFO" label.color="$color"
fi
