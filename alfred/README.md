# Alfred Configuration

This directory contains **only custom Alfred configurations** - default settings are excluded.

## Structure

```
alfred/
└── Library/
    └── Application Support/
        └── Alfred/
            └── Alfred.alfredpreferences/
                └── resources/      # Custom web search icons (4 files)
```

## What's Included

**Only custom/personalized configurations** - 5 files, 44KB total.

- **4 custom web search icons** (resources/)

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

- Total size: **44KB (5 files)**
- **Only truly custom content** - 4 web search icons you created
- Alfred will apply all default settings on first launch
- Works with Alfred 5.x
