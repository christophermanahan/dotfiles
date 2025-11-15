function icon_map() {
  case "$1" in
  # Terminal apps
  "WezTerm" | "wezterm-gui")
    icon_result=""
    ;;
  # Browsers
  "Google Chrome")
    icon_result="󰊯"
    ;;
  "Firefox")
    icon_result="󰈹"
    ;;
  "Safari")
    icon_result="󰀹"
    ;;
  "qutebrowser")
    icon_result=""
    ;;
  "Ladybird")
    icon_result="󰖟"
    ;;
  "Brave Browser")
    icon_result="󰊯"
    ;;
  # Communication
  "Slack")
    icon_result="󰒱"
    ;;
  "Discord")
    icon_result="󰙯"
    ;;
  "WhatsApp")
    icon_result="󰖣"
    ;;
  "zoom.us")
    icon_result="󰍹"
    ;;
  "Duo Desktop")
    icon_result="󰍡"
    ;;
  "Live")
    icon_result="󰽲"
    ;;
  "Alfred" | "Alfred 5" | "Alfred Preferences")
    icon_result="󰘧"
    ;;
  "1Password")
    icon_result="󰟵"
    ;;
  "Obsidian")
    icon_result=""
    ;;
  "Craft")
    icon_result="󱓷"
    ;;
  # Apple apps
  "Keynote")
    icon_result="󰈙"
    ;;
  "Pages")
    icon_result=""
    ;;
  "Preview")
    icon_result=""
    ;;
  "Numbers")
    icon_result="󰎚"
    ;;
  "Finder")
    icon_result=""
    ;;
  "System Preferences" | "System Settings")
    icon_result=""
    ;;
  # Google apps
  "Google Docs" | "Google Sheets" | "Google Slides" | "Google Drive")
    icon_result="󰊯"
    ;;
  # Development
  "Lens")
    icon_result=""
    ;;
  "OrbStack")
    icon_result="󰡨"
    ;;
  "Neo4j Desktop 2")
    icon_result="󰆼"
    ;;
  # Karabiner
  "Karabiner-Elements" | "Karabiner-EventViewer")
    icon_result="⌨"
    ;;
  # Media
  "Stremio")
    icon_result="󰷝"
    ;;
  # Utilities
  "AeroSpace")
    icon_result="󱂬"
    ;;
  "kindaVim" | "Wooshy" | "Scrolla")
    icon_result="󰘶"
    ;;
  "Splice")
    icon_result="󰎆"
    ;;
  # Default fallback
  *)
    icon_result=""
    ;;
  esac
  echo "$icon_result"
}

icon_map "$1"
