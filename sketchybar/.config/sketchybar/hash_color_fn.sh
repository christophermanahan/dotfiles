#!/bin/sh

# Generate a deterministic color from app name using hash
function hash_color() {
  local app_name="$1"

  # Define 10 distinct colors (spread across color wheel)
  local colors=(
    "0xffff8888"  # Coral Red (muted)
    "0xffff9d00"  # Bright Orange
    "0xffffd700"  # Bright Gold
    "0xff50fa7b"  # Bright Green
    "0xff00d4aa"  # Bright Teal
    "0xff5599ff"  # Bright Blue
    "0xff6b5cff"  # Bright Indigo
    "0xffbb88ff"  # Bright Purple
    "0xffff69b4"  # Bright Pink
    "0xffffb380"  # Peach
  )

  # Generate hash from app name (use cksum for portability)
  local hash=$(echo -n "$app_name" | cksum | awk '{print $1}')

  # Select color deterministically using modulo
  local color_index=$((hash % 10))

  # Return the selected color
  echo "${colors[$color_index]}"
}

hash_color "$1"
