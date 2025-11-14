#!/bin/sh

source "$CONFIG_DIR/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ $PERCENTAGE = "" ]; then
  exit 0
fi

case ${PERCENTAGE} in
  100) ICON="󰁹"
  ;;
  9[0-9]) ICON="󰂂"
  ;;
  8[0-9]) ICON="󰂁"
  ;;
  7[0-9]) ICON="󰂀"
  ;;
  6[0-9]) ICON="󰁿"
  ;;
  5[0-9]) ICON="󰁾"
  ;;
  4[0-9]) ICON="󰁽"
  ;;
  3[0-9]) ICON="󰁼"
  ;;
  2[0-9]) ICON="󰁻"
  ;;
  1[0-9]) ICON="󰁺"
  ;;
  *) ICON=""
esac

# Set color based on percentage
if [[ $CHARGING != "" ]]; then
  ICON="󰂄"
  COLOR="0xff89dceb"  # Cyan for charging
elif [ $PERCENTAGE -ge 80 ]; then
  COLOR="0xffa6e3a1"  # Green for high battery
elif [ $PERCENTAGE -ge 40 ]; then
  COLOR="0xfff9e2af"  # Yellow for medium battery
elif [ $PERCENTAGE -ge 20 ]; then
  COLOR="0xfffab387"  # Orange for low battery
else
  COLOR="0xfff38ba8"  # Red for critical battery
fi

sketchybar --set $NAME icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
