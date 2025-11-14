#!/bin/sh

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icon_map_fn.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=on \
                         background.color=0x40000000 \
                         background.corner_radius=8 \
                         background.y_offset=-0.5 \
                         icon.color=$WHITE \
                         label.color=$PASTEL_FUCHSIA
else
  sketchybar --set $NAME background.drawing=off \
                         icon.color=$WHITE \
                         label.color=$PASTEL_FUCHSIA
fi

# Load all icons on startup
for sid in $(aerospace list-workspaces --all); do
  apps=$(aerospace list-windows --workspace "$sid" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  sketchybar --set space.$sid drawing=on

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app; do
      icon=$(icon_map "$app")
      icon_strip+="$icon "
    done <<<"${apps}"
  else
    icon_strip=" —"
  fi
  sketchybar --animate sin 10 --set space.$sid label="$icon_strip"
done
