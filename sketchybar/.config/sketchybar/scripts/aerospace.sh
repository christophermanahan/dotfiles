#!/bin/sh

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icon_map_fn.sh"
source "$CONFIG_DIR/hash_color_fn.sh"

# Strip invisible Unicode characters (like LEFT-TO-RIGHT MARK U+200E)
strip_invisible() {
  # Remove common invisible Unicode: LTR mark, RTL mark, zero-width space, etc.
  echo "$1" | sed 's/[​‎‏]//g'
}

# Get the focused app name
FOCUSED_APP=$(aerospace list-windows --focused | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
FOCUSED_APP=$(strip_invisible "$FOCUSED_APP")
APP_COLOR=$(hash_color "$FOCUSED_APP")

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME background.drawing=on \
                         background.color=0x40000000 \
                         background.corner_radius=8 \
                         background.y_offset=-0.5 \
                         background.border_width=1 \
                         background.border_color=$WHITE \
                         icon.color=$WHITE \
                         label.color="$APP_COLOR"
else
  sketchybar --set $NAME background.drawing=off \
                         icon.color=$WHITE \
                         label.color=$WHITE
fi

# Load all icons on startup
for sid in $(aerospace list-workspaces --all); do
  apps=$(aerospace list-windows --workspace "$sid" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  sketchybar --set space.$sid drawing=on

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app; do
      # Strip invisible Unicode characters before icon lookup
      clean_app=$(strip_invisible "$app")
      icon=$(icon_map "$clean_app")
      icon_strip+="$icon "
    done <<<"${apps}"
  else
    icon_strip=" —"
  fi
  sketchybar --animate sin 10 --set space.$sid label="$icon_strip"
done
