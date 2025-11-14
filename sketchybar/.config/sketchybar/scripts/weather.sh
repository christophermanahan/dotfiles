#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# Fetch weather data from wttr.in (auto-detect location via IP)
WEATHER_JSON=$(curl -s "https://wttr.in/?format=j1" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$WEATHER_JSON" ]; then
  # Parse current temperature and condition (handle spaces in JSON)
  TEMP=$(echo "$WEATHER_JSON" | grep '"temp_F"' | head -1 | grep -o '"[0-9]*"' | grep -o '[0-9]*')
  CONDITION=$(echo "$WEATHER_JSON" | grep '"value"' | head -1 | sed 's/.*"value"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

  # Choose icon based on condition
  case "$CONDITION" in
    *"Clear"*|*"Sunny"*)
      ICON=""
      COLOR="0xfff9e2af"  # Yellow
      ;;
    *"Partly cloudy"*)
      ICON=""
      COLOR="0xfffab387"  # Peach
      ;;
    *"Cloudy"*|*"Overcast"*)
      ICON=""
      COLOR="0xffa6adc8"  # Gray
      ;;
    *"rain"*|*"Rain"*|*"mist"*|*"Mist"*)
      ICON=""
      COLOR="0xff89dceb"  # Cyan
      ;;
    *"storm"*|*"Storm"*|*"thunder"*)
      ICON=""
      COLOR="0xfff38ba8"  # Red
      ;;
    *"snow"*|*"Snow"*)
      ICON=""
      COLOR="0xff89b4fa"  # Blue
      ;;
    *"Fog"*)
      ICON=""
      COLOR="0xffa6adc8"  # Gray
      ;;
    *)
      ICON=""
      COLOR="$WHITE"
      ;;
  esac

  sketchybar --set $NAME icon="$ICON" \
                         icon.color="$COLOR" \
                         label="${TEMP}°F"
else
  # Fallback if weather fetch fails
  sketchybar --set $NAME icon="" label="--°F"
fi
