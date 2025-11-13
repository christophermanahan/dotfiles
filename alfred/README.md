# Alfred Configuration

This directory contains **only custom Alfred configurations** - default settings are excluded.

## Structure

```
alfred/
└── Library/
    └── Application Support/
        └── Alfred/
            └── Alfred.alfredpreferences/
                ├── resources/      # Custom web search icons (4 files)
                └── remote/         # Alfred Remote custom pages & images
```

## What's Included

**Only custom/personalized configurations** - 16 files, 232KB total.

- **4 custom web search icons** (resources/)
- **5 Alfred Remote page layouts** (remote/pages/)
- **5 custom Remote page background images** (remote/images/pages/)

**What's NOT included:**
- Default web searches (Google, Amazon, YouTube, etc.)
- Default feature preferences (calculator, contacts, etc.)
- Default appearance settings
- Default Alfred Remote item icons (64 default app/system icons)
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

**Note:** Alfred will use its defaults for everything except your custom searches and Remote config.

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
# Custom searches and Remote pages will be available immediately
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

- Total size: 232KB (16 files)
- **Only truly custom configurations** - no defaults
- Alfred Remote will use default item icons automatically
- Alfred will apply default settings on first launch
- Works with Alfred 5.x
