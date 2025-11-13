# Alfred Configuration

This directory contains **only custom Alfred configurations** - default settings are excluded.

## Structure

```
alfred/
└── Library/
    └── Application Support/
        └── Alfred/
            └── Alfred.alfredpreferences/
                ├── preferences/    # Custom feature preferences (7 files)
                │   ├── appearance/options/prefs.plist
                │   └── features/
                │       ├── calculator/prefs.plist
                │       ├── clipboard/prefs.plist
                │       ├── contacts/prefs.plist
                │       ├── itunes/prefs.plist
                │       ├── system/prefs.plist
                │       └── terminal/prefs.plist
                └── resources/      # Custom web search icons (4 files)
```

## What's Included

**Only custom/personalized configurations** - 12 files, 72KB total.

### Custom Preferences (7 files)
- **calculator**: Disabled
- **contacts**: Disabled
- **clipboard**: Custom hotkey (Cmd+Opt+C), 2-item limit, 3-month persistence
- **itunes/music**: All features disabled
- **terminal**: WezTerm integration with CLI support
- **system**: Custom keywords (`et` for empty trash, `lock` for screensaver), volume controls disabled
- **appearance**: Auto-highlight disabled, hat/menu hidden, custom screen positioning

### Custom Resources (4 files)
- **4 custom web search icons** (Twitch, Calendar, Docs, Weather)

**What's NOT included:**
- Default web searches (Google, Amazon, YouTube, etc.)
- Default feature preferences (calculator, contacts, etc.)
- Default appearance settings
- Default Alfred Remote item icons (64 default app/system icons)
- Alfred Remote pages and layouts (all defaults)
- Workflows (none created yet)

## Installation

### Prerequisites

- [Alfred](https://www.alfredapp.com/) with Powerpack
- GNU Stow (`brew install stow`)

### Deploy Configuration

```bash
# Remove existing preferences (if present)
rm -rf ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences

# Deploy with stow
cd ~/paradiddle
stow alfred
```

Symlink created:
```
~/Library/Application Support/Alfred/Alfred.alfredpreferences
  → ~/paradiddle/alfred/Library/Application Support/Alfred/Alfred.alfredpreferences
```

**Note:** Alfred will use its defaults for everything except your custom web search icons.

## Updating Configuration

```bash
# Changes are automatically reflected (symlinked)
cd ~/paradiddle
git add alfred/
git commit -m "chore: update Alfred custom searches"
git push
```

## New Mac Setup

```bash
# Install Alfred
brew install --cask alfred

# Deploy configuration
cd ~/paradiddle
stow alfred

# Open Alfred and enter Powerpack license
# Custom searches will be available immediately
```

## Troubleshooting

### Stow Conflicts

```bash
# Check for conflicts (dry run)
stow -n alfred

# Remove existing config if needed
rm -rf ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences
stow alfred
```

### Alfred Not Loading Custom Searches

1. Quit Alfred completely
2. Verify symlink: `ls -la ~/Library/Application\ Support/Alfred/`
3. Reopen Alfred
4. Check Preferences → Features → Web Search for custom searches

## Notes

- Total size: **72KB (12 files)**
- **Only truly custom content** - 7 preference files with your custom settings + 4 web search icons
- Alfred will apply defaults for any preferences not included (web searches, file search, dictionary, etc.)
- **WezTerm integration**: Terminal script uses `wezterm cli send-text` for proper command execution
- Works with Alfred 5.x
