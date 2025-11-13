# Alfred Configuration

This directory contains Alfred preferences that can be deployed using GNU Stow.

## Structure

```
alfred/
└── Library/
    └── Application Support/
        └── Alfred/
            └── Alfred.alfredpreferences/
                ├── preferences/    # Alfred settings
                ├── remote/         # Alfred Remote configuration
                └── resources/      # Themes, snippets, workflows
```

## Installation

### Prerequisites

- [Alfred](https://www.alfredapp.com/) installed (requires Powerpack for sync)
- GNU Stow (install via: `brew install stow`)

### Deploy Configuration

**Important:** This will replace your existing Alfred preferences. Backup first if needed!

```bash
# 1. Remove existing Alfred preferences (if present)
rm -rf ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences

# 2. Deploy Alfred configuration with stow
cd ~/paradiddle
stow alfred

# 3. Restart Alfred (or quit and reopen)
```

This creates a symlink:
```
~/Library/Application Support/Alfred/Alfred.alfredpreferences
  → ~/paradiddle/alfred/Library/Application Support/Alfred/Alfred.alfredpreferences
```

## What's Included

- **Appearance settings**: Theme, fonts, colors
- **Feature preferences**: Calculator, contacts, clipboard, snippets
- **Web searches**: Custom search engines and keywords
- **Workflows**: Custom automation workflows (if any)
- **Remote settings**: Alfred Remote app configuration
- **Resources**: Themes and other resources

## What's NOT Included

These files are in the parent Alfred directory but excluded to avoid syncing sensitive data:

- `powerpack.*.dat` - License file (keep local)
- `prefs.json` - Machine-specific preferences
- `usage.data` - Usage statistics
- `Databases/` - Search index (rebuilt by Alfred)

## Updating Configuration

After making changes in Alfred:

```bash
# Changes are automatically reflected in the repo (symlinked)
cd ~/paradiddle
git add alfred/
git commit -m "chore: update Alfred configuration"
git push
```

## New Mac Setup

On a new Mac, after cloning the paradiddle repo:

```bash
# Install Alfred first
brew install --cask alfred

# Deploy configuration
cd ~/paradiddle
stow alfred

# Open Alfred and enter your Powerpack license
# Your preferences will be loaded automatically
```

## Troubleshooting

### Stow Conflicts

If stow reports conflicts:

```bash
# Check what's conflicting
stow -n alfred  # Dry run

# Remove conflicting files manually, then stow
rm -rf ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences
stow alfred
```

### Alfred Not Recognizing Preferences

1. Quit Alfred completely
2. Verify symlink exists: `ls -la ~/Library/Application\ Support/Alfred/`
3. Reopen Alfred
4. Check Alfred Preferences to confirm settings loaded

## Notes

- Alfred preferences are stored as binary `.plist` files
- Total size: ~2MB (128 files)
- Works with Alfred 5.x (current version as of 2025)
