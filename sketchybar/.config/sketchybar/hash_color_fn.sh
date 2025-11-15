#!/bin/sh

# Generate a deterministic color from app name using hash
function hash_color() {
  local app_name="$1"

  # Define 10 distinct neon pastel colors (spread across color wheel)
  local colors=(
    "0xffff5555"  # Bright Red
    "0xffff9d00"  # Bright Orange
    "0xffffd700"  # Bright Gold
    "0xff50fa7b"  # Bright Green
    "0xff00f5ff"  # Bright Cyan
    "0xff5599ff"  # Bright Blue
    "0xffbb88ff"  # Bright Purple
    "0xffff55ff"  # Bright Magenta
    "0xffaaff00"  # Bright Lime
    "0xffff69b4"  # Bright Pink
  )

  # Generate hash from app name (use cksum for portability)
  local hash=$(echo -n "$app_name" | cksum | awk '{print $1}')

  # Select color deterministically using modulo
  local color_index=$((hash % 10))

  # Return the selected color
  echo "${colors[$color_index]}"
}

hash_color "$1"
