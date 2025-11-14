# Alfred Configuration

This directory contains **only custom Alfred configurations** - default settings are excluded.

## Structure

```
alfred/
└── Alfred.alfredpreferences/
    ├── preferences/    # Custom feature preferences (9 files)
    │   ├── appearance/options/prefs.plist
    │   └── features/
    │       ├── calculator/prefs.plist
    │       ├── clipboard/prefs.plist
    │       ├── contacts/prefs.plist
    │       ├── itunes/prefs.plist
    │       ├── system/prefs.plist
    │       ├── terminal/prefs.plist
    │       ├── webbookmarks/prefs.plist
    │       └── websearch/prefs.plist
    └── resources/      # Custom web search icons (4 files)
```

## What's Included

**Only custom/personalized configurations** - 14 files, 74KB total.

### Custom Preferences (9 files)
- **calculator**: Disabled
- **contacts**: Disabled
- **clipboard**: Custom hotkey (Cmd+Opt+C), 2-item limit, 3-month persistence
- **itunes/music**: All features disabled
- **terminal**: WezTerm integration with CLI support
- **system**: Custom keywords (`et` for empty trash, `lock` for screensaver), volume controls disabled
- **appearance**: Auto-highlight disabled, hat/menu hidden, custom screen positioning
- **websearch**: 4 custom web searches
  - `w` - Weather (Google weather search)
  - `d` - Search docs (Google Docs)
  - `cal` - Open calendar (Google Calendar)
  - `t` - Open twitch (Twitch.tv)
- **webbookmarks**: Custom keyword `b`, mode 1

### Custom Resources (4 files)
- **4 custom web search icons** (Twitch, Calendar, Docs, Weather)

**What's NOT included:**
- Default web searches (Google, Amazon, YouTube, etc.)
- Default feature preferences (file search, dictionary, etc.)
- Default appearance settings
- Default Alfred Remote item icons (64 default app/system icons)
- Alfred Remote pages and layouts (all defaults)
- Workflows (installed separately from Alfred Gallery, see below)

## Recommended Workflows

These workflows are installed from the [Alfred Gallery](https://alfred.app/) and are **not** version controlled in this repo:

### 1. [Chromium Bookmarks and History Search](https://alfred.app/)
Search Chrome/Chromium bookmarks and browsing history directly from Alfred.
- Fast bookmark search with favicon display
- Recent history browsing
- Domain-based grouping
- Open in browser or copy URL actions

### 2. [Menu Bar Search](https://alfred.app/)
Search and execute menu bar items from any application.
- Real-time menu indexing using Accessibility APIs
- Fuzzy search across all menu items
- Execute menu actions without mouse navigation
- Requires Accessibility permissions

### 3. [1Password](https://alfred.app/)
Quick access to 1Password items and vaults.
- Search across all vaults
- Copy passwords, usernames, OTP codes
- Open items in 1Password app
- Requires 1Password CLI: `brew install 1password-cli`

**Installation:** Open Alfred → Workflows → "+" → Alfred Gallery → Search for workflow name

## Installation

### Prerequisites

- [Alfred](https://www.alfredapp.com/) with Powerpack
- This repository cloned to `~/paradiddle`

### Setup Alfred Sync (Recommended Method)

Alfred has a built-in sync feature that's designed for preferences management. This is the proper way to sync Alfred configurations:

**Step 1: Install Alfred**
```bash
brew install --cask alfred
```

**Step 2: Configure Alfred to use this directory**

1. Open Alfred Preferences (`Cmd + ,`)
2. Go to **Advanced** tab
3. Click **Set preferences folder...**
4. Navigate to and select: `~/paradiddle/alfred/Alfred.alfredpreferences`
5. Alfred will reload and use this directory for all preferences

**Step 3: Enter Powerpack License**

Open Alfred and enter your Powerpack license key.

That's it! Alfred now reads and writes preferences directly from the repo directory.

### How It Works

- **Alfred manages the directory directly** - No symlinks needed
- **Changes sync automatically** - Any preference changes in Alfred are written to the repo
- **Git tracks changes** - Commit and push changes to sync across machines
- **Clean separation** - Alfred creates additional runtime files (cache, etc.) in `~/Library/Application Support/Alfred/` but preferences stay in the repo

### Alternative: Manual Copy Method

If you prefer not to use Alfred's sync feature:

```bash
# Backup existing preferences (if any)
cp -r ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences \
     ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences.backup

# Copy custom preferences
cp -r alfred/Alfred.alfredpreferences/* \
     ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences/
```

**Note:** With this method, you'll need to manually copy files back to the repo after making changes in Alfred.

## Updating Configuration

### If using Alfred's sync folder feature:
```bash
# Changes are automatically saved to the repo
cd ~/paradiddle
git add alfred/
git commit -m "chore: update Alfred preferences"
git push
```

### If using manual copy method:
```bash
# Copy changes from Alfred back to repo
cp -r ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences/* \
     ~/paradiddle/alfred/Alfred.alfredpreferences/

# Commit changes
cd ~/paradiddle
git add alfred/
git commit -m "chore: update Alfred preferences"
git push
```

## New Mac Setup

```bash
# Install Alfred
brew install --cask alfred

# Clone repo (if not already)
git clone https://github.com/christophermanahan/paradiddle.git ~/paradiddle

# Configure Alfred sync
# 1. Open Alfred Preferences (Cmd + ,)
# 2. Advanced → Set preferences folder
# 3. Select: ~/paradiddle/alfred/Alfred.alfredpreferences
# 4. Enter Powerpack license

# Done! Your custom preferences and searches are now active
```

## Troubleshooting

### Alfred Not Loading Custom Preferences

1. **Verify sync folder path:**
   - Alfred Preferences → Advanced → Syncing
   - Should show: `~/paradiddle/alfred/Alfred.alfredpreferences`

2. **Check folder permissions:**
   ```bash
   ls -la ~/paradiddle/alfred/Alfred.alfredpreferences/
   # Should be readable/writable by your user
   ```

3. **Force reload:**
   - Quit Alfred completely (`Cmd + Q` from Alfred Preferences)
   - Reopen Alfred
   - Check Preferences → Features to verify custom settings

### Custom Web Searches Not Appearing

1. Open Alfred Preferences
2. Go to **Features → Web Search**
3. Custom searches should appear with your custom icons
4. If missing, verify files exist in `alfred/Alfred.alfredpreferences/resources/`

### WezTerm Integration Not Working

The terminal integration uses WezTerm's CLI. Verify:
```bash
# Check WezTerm CLI is available
/Applications/WezTerm.app/Contents/MacOS/wezterm cli --help

# Test manually
# 1. Open WezTerm
# 2. In Alfred, search ">" followed by a command
# 3. Command should execute in WezTerm
```

If still not working, check `alfred/Alfred.alfredpreferences/preferences/features/terminal/prefs.plist` contains the correct WezTerm CLI command.

## Notes

- **Total size:** 74KB (14 files)
- **Only truly custom content:** 9 preference files with your custom settings + 4 web search icons + 1 README
- **Alfred will apply defaults** for any preferences not included (web searches, file search, dictionary, etc.)
- **WezTerm integration:** Terminal script uses `wezterm cli send-text` for proper command execution
- **No symlinks needed:** Alfred's native sync feature handles everything
- **Works with:** Alfred 5.x with Powerpack

## Why Not Use Stow?

Alfred actively writes to its preferences directory, which breaks symlinks created by stow. Alfred's built-in sync feature is designed specifically for this use case and handles:
- File locking during writes
- Atomic updates to prevent corruption
- Proper permissions management
- Runtime file separation (cache vs preferences)

Using Alfred's native sync is the recommended and most reliable method.
