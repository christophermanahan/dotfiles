#!/bin/sh

# Generate a deterministic color from app name using hash
function hash_color() {
  local app_name="$1"

  # Generate hash from app name (use cksum for portability)
  local hash=$(echo -n "$app_name" | cksum | awk '{print $1}')

  # Extract RGB components from hash (ensure good color distribution)
  local r=$(( (hash >> 16) % 156 + 100 ))  # 100-255 range
  local g=$(( (hash >> 8) % 156 + 100 ))   # 100-255 range
  local b=$(( hash % 156 + 100 ))          # 100-255 range

  # Format as hex color with full opacity
  printf "0xff%02x%02x%02x" $r $g $b
}

hash_color "$1"
