# Command Creator Development Log

This document tracks the development and enhancement of the Command Creator system in Paradiddle.

## Session: 2025-10-28 - Tmux Scrolling Fix & Keybinding Remapping

### Problem 1: Tmux Scrolling with CTRL+q

**Issue:** CTRL+q worked for scrolling in all floating terminals except tmux.

**Root Cause:**
- CTRL+q enters Neovim terminal normal mode, which allows scrolling the Neovim terminal buffer
- Other terminals (Claude, k9s, lazygit) output directly to the Neovim terminal buffer, so CTRL+q scrolling works
- Tmux maintains its own separate scrollback buffer that CTRL+q cannot access

**Solution Implemented:**

1. **Added mouse mode to tmux** (`~/.tmux.conf`):
   ```bash
   set -g mouse on                  # Enable trackpad/mouse scrolling
   set -g history-limit 50000       # 50k line scrollback buffer
   setw -g mode-keys vi             # Vi-style navigation in copy mode
   bind -n C-q copy-mode            # CTRL+q enters tmux copy mode
   bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
   ```

2. **Made CTRL+q tmux-aware** (`nvim/.config/nvim/lua/mappings.lua:22-44`):
   ```lua
   map("t", "<C-q>", function()
     local bufnr = vim.api.nvim_get_current_buf()
     local chan = vim.b[bufnr].terminal_job_id

     if chan then
       -- Check if tmux is running by looking at the global tracking variable
       local nvim_pid = vim.fn.getpid()
       local term_id = "floatTerm_" .. nvim_pid
       local is_tmux = _G.tmux_sessions and _G.tmux_sessions[term_id]

       if is_tmux then
         -- Send CTRL+q directly to tmux (tmux will catch it with bind -n C-q copy-mode)
         vim.api.nvim_chan_send(chan, "\x11")  -- \x11 is CTRL+q
       else
         -- Regular terminal: enter Neovim normal mode
         vim.cmd("stopinsert")
       end
     else
       -- Fallback: enter normal mode
       vim.cmd("stopinsert")
     end
   end, { desc = "Enter terminal normal mode (or tmux copy mode)" })
   ```

**How It Works:**
- Detects if you're in the tmux terminal using `_G.tmux_sessions` tracking
- If in tmux: sends CTRL+q character (`\x11`) to tmux, which enters copy mode
- If in other terminals: enters Neovim normal mode as before

**Usage:**
- **Tmux terminal (ALT+i)**:
  - Trackpad scrolling works automatically (no key press needed)
  - CTRL+q enters tmux copy mode, scroll with `j`/`k`, exit with `q`
  - CTRL+f [ also works (traditional tmux copy mode)
- **Other terminals**: CTRL+q enters Neovim normal mode, exit with `i`

---

### Problem 2: Keybinding Conflict

**Issue:** ALT+x conflicted with tmux's ALT+x binding (kill pane).

**Solution:** Remapped command search from **ALT+x** to **ALT+q**.

**Files Changed:**

1. **`nvim/.config/nvim/lua/mappings.lua:385-387`**
   ```lua
   -- Alt+Q: Fuzzy search all executables (floating terminal)
   -- Note: Changed from Alt+X to avoid conflict with tmux's Alt+X (kill pane)
   map({ "n", "t" }, "<A-q>", function()
   ```

2. **`zsh/.zshrc:114-116`**
   ```bash
   # Main command search widget (Alt+Q)
   # Note: Changed from Alt+X to avoid conflict with tmux's Alt+X (kill pane)
   fzf-command-widget() {
   ```

3. **`zsh/.zshrc:144`** - Updated fzf header to show `Alt+Q`

4. **`CLAUDE.md:43-44`** - Updated documentation

**New Keybinding Layout:**
- **`Alt+Q`**: Main command search (all commands + subcommands) ← CHANGED
- **`Alt+Shift+G`**: Git commands only
- **`Alt+Shift+D`**: Docker/K8s commands
- **`Alt+Shift+A`**: AWS/Cloud commands
- **`Alt+Shift+X`**: Aliases and functions
- **`Alt+Shift+B`**: Homebrew packages

---

## Current Command Creator System

### Architecture

**Location:** Primarily in `zsh/.zshrc` and `nvim/.config/nvim/lua/mappings.lua`

**Key Components:**

1. **Command Cache System**
   - Static database: 13 CLIs with 500+ subcommands (curated)
   - Cache location: `~/.cache/paradiddle/commands.db`
   - Auto-updates every 7 days
   - Helper scripts: `paradiddle-update-commands`, `paradiddle-add-command`

2. **Two-Stage Command Builder** (Alt+Q)
   - **Stage 1**: Select command via fzf (e.g., "docker build", "git commit")
   - **Stage 2**: Interactive flag picker (if flags available)
   - Generates complete command with selected flags

3. **Specialized Search Variants**
   - Git commands (Alt+Shift+G)
   - Docker/K8s (Alt+Shift+D)
   - AWS/Cloud (Alt+Shift+A)
   - Aliases/Functions (Alt+Shift+X)
   - Homebrew packages (Alt+Shift+B)

### Key Features

- **Hierarchical search**: Find subcommands (e.g., "git stash pop", "docker container ls")
- **Real-time fuzzy filtering**: Type to narrow results
- **Preview window**: Shows command-specific help (`--help`, man pages)
- **Interactive controls**:
  - `Ctrl+/`: Toggle preview window
  - `Enter`: Insert command at cursor (safe, doesn't execute)
  - `Ctrl+E`: Execute command immediately
  - `Ctrl+U`: Force update command cache

### Coverage (500+ commands)

| CLI | Commands | Example Subcommands |
|-----|----------|---------------------|
| docker | 93 | container ls, image build, network create |
| aws | 89 | s3 ls, ec2 describe-instances, ecs list-clusters |
| npm | 64 | install, run, test, build, publish |
| kubectl | 63 | get pods, describe deployment, apply |
| git | 50 | stash pop, remote add, branch delete |
| helm | 40 | repo add, install, upgrade |
| cargo | 36 | build, test, run, clippy |
| terraform | 35 | apply, plan, state list |
| docker-compose | 24 | up, down, build, logs |

---

## Future Enhancement Ideas

### 1. Command History Integration
- Show recently used commands with timestamps
- Filter by frequency or recency
- Quick access to last N commands

### 2. Command Favorites/Bookmarks
- Save frequently used commands with custom names
- Organize into categories
- Quick recall via dedicated keybinding

### 3. Command Templates
- Pre-filled command patterns with placeholders
- Example: "docker run with volume mount and port"
- Template variables: `${PORT}`, `${IMAGE}`, `${VOLUME}`

### 4. Enhanced Flag Descriptions
- Richer documentation in flag picker
- Show examples for each flag
- Indicate required vs optional flags

### 5. Multi-Command Workflows
- Chain multiple commands together
- Save as reusable workflows
- Example: "Build → Test → Deploy"

### 6. Command Validation
- Check if required flags are present
- Validate flag values (e.g., port numbers, file paths)
- Show warnings before execution

### 7. Command Snippets Library
- Store complex command patterns with placeholders
- Community-contributed snippets
- Import/export snippet collections

### 8. Context-Aware Suggestions
- Suggest commands based on current directory
- Git commands in git repos
- Docker commands when Dockerfile present
- Kubernetes commands when kubeconfig detected

### 9. Command Builder GUI
- Visual interface for building commands
- Drag-and-drop flag selection
- Real-time preview of final command

### 10. AI-Powered Command Assistant
- Natural language to command translation
- Example: "list all running docker containers" → `docker ps`
- Command explanation in plain English
- Suggest related commands

---

## Technical Implementation Notes

### Foreground Terminal Tracking System

**Added:** User added a sophisticated terminal management system (mappings.lua:49-152)

**Purpose:** Handles multiple floating terminals stacking on top of each other

**Key Functions:**
- `find_term_window(term_id)`: Locate terminal window and buffer
- `find_term_buffer(term_id)`: Find terminal buffer (even if hidden)
- `prepare_toggle(term_id)`: Smart toggle with foreground awareness

**Logic:**
1. **Case 1**: Target doesn't exist → Open it
2. **Case 2**: Target is focused → Close it
3. **Case 3**: Target hidden behind another terminal → Hide foreground, reveal target
4. **Case 4**: No conflict → Normal toggle

This system ensures clean terminal switching without visual glitches or stacking issues.

---

## Testing Checklist

When modifying Command Creator:

- [ ] Test Alt+Q command search in Neovim
- [ ] Test Alt+Q command search in shell (outside Neovim)
- [ ] Verify flag picker launches for commands with flags
- [ ] Test Enter (insert) vs Ctrl+E (execute) behavior
- [ ] Verify cache updates with Ctrl+U
- [ ] Test all variant keybindings (Shift+G/D/A/X/B)
- [ ] Confirm no conflicts with tmux keybindings
- [ ] Verify preview window toggle (Ctrl+/)
- [ ] Test in both normal and terminal mode in Neovim
- [ ] Confirm tmux terminal properly tracked in global state

---

## Related Files

- `nvim/.config/nvim/lua/mappings.lua` - Neovim keybindings
- `zsh/.zshrc` - Shell command widgets and keybindings
- `~/.tmux.conf` - Tmux configuration (mouse mode, copy mode)
- `CLAUDE.md` - User-facing documentation
- `~/.cache/paradiddle/commands.db` - Command cache

---

## Notes for Future Development

1. **Performance**: Current system handles 500+ commands well. If expanding to 1000+, consider:
   - Lazy loading categories
   - Indexing/search optimization
   - Background cache updates

2. **Extensibility**: Consider plugin architecture for:
   - Custom command sources
   - Custom flag parsers
   - Third-party integrations

3. **Discoverability**: Users may not know about:
   - The two-stage builder
   - Ctrl+E immediate execution
   - Cache update mechanism
   - Consider adding help overlay (Ctrl+?)

4. **Integration Opportunities**:
   - Claude Code integration for command suggestions
   - Integration with command history tools (atuin, mcfly)
   - Export commands to shell aliases
   - Generate shell scripts from command chains

---

## Session End State

All features working as expected:
- ✅ CTRL+q scrolling in tmux terminal
- ✅ ALT+q command search (remapped from ALT+x)
- ✅ No keybinding conflicts with tmux
- ✅ Documentation updated
- ✅ Foreground terminal tracking system integrated
- ✅ Ready for further development

Next session focus: Discuss and implement priority enhancements from the ideas list above.
