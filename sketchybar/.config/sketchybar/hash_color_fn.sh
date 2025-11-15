#!/bin/sh

# Generate a deterministic color from app name using hash
function hash_color() {
  local app_name="$1"

  # Define 10 neon pastel colors
  local colors=(
    "0xffff6ec7"  # Neon Pink
    "0xff8bffa3"  # Neon Mint Green
    "0xffffb86c"  # Neon Peach
    "0xff7dd3fc"  # Neon Sky Blue
    "0xffffa6ff"  # Neon Lavender
    "0xffffeb3b"  # Neon Lemon
    "0xffff6b6b"  # Neon Coral
    "0xff6bffcc"  # Neon Aqua
    "0xffffaa00"  # Neon Orange
    "0xffbd93f9"  # Neon Purple
  )

  # Generate hash from app name (use cksum for portability)
  local hash=$(echo -n "$app_name" | cksum | awk '{print $1}')

  # Select color deterministically using modulo
  local color_index=$((hash % 10))

  # Return the selected color
  echo "${colors[$color_index]}"
}

hash_color "$1"
