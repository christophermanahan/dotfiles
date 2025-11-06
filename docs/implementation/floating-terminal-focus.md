# Floating Terminal Focus Management

## Problem Statement

In Paradiddle's floating terminal system, when multiple terminals are open and stacked on top of each other, pressing a keyboard shortcut for a terminal that's already open but hidden behind another terminal would simply toggle it off instead of bringing it to the foreground.

**User Experience Issue:**
- Open Claude terminal (ALT+k)
- Open tmux terminal (ALT+i) - Claude now hidden behind tmux
- Press ALT+k again → Claude toggles off instead of coming to foreground
- Result: User has to press ALT+k twice (once to close, once to reopen) to see Claude

## Requirements

1. **Preserve terminal state** - Never close/reopen terminals (CLI history, running processes must persist)
2. **Keep stacked terminals** - Don't hide all other terminals, maintain the visual stack
3. **Smart switching** - When pressing a shortcut for a hidden terminal, reveal it by closing the foreground terminal
4. **Buffer-aware** - Track terminals by buffer (not just window) since NvChad's `term.toggle()` closes windows but keeps buffers alive

## Solution: Foreground Terminal Tracking

### Architecture

**Global State Tracking:**
```lua
-- Track which terminal is currently in the foreground
_G.foreground_terminal = nil

-- Track terminal buffers (persists even when window closes)
_G.terminal_buffers = {}
```

**Helper Functions:**

1. **`find_term_window(term_id)`** - Find terminal window by term_id
   - Returns: `window_id, buffer_number` or `nil, nil`
   - Searches all windows for matching terminal buffer

2. **`find_term_buffer(term_id)`** - Find terminal buffer even if window is closed
   - Returns: `buffer_number` or `nil`
   - Checks tracked buffers first, then searches all buffers
   - Critical for detecting terminals that NvChad has toggled closed

3. **`prepare_toggle(term_id)`** - Smart toggle logic with 4 cases
   - Returns: `true` if should proceed with toggle, `false` if already handled

### Four Cases Logic

**Case 1: Opening a new terminal**
```lua
if not target_win and not target_buf then
  -- Terminal doesn't exist (no window, no buffer)
  _G.foreground_terminal = term_id
  return true  -- Proceed with toggle (opens it)
end
```

**Case 2: Closing focused terminal**
```lua
if current_buf == target_buf then
  -- User pressed shortcut for currently focused terminal
  _G.foreground_terminal = nil
  return true  -- Proceed with toggle (closes it)
end
```

**Case 3: Revealing hidden terminal** (The key innovation)
```lua
if _G.foreground_terminal and _G.foreground_terminal ~= term_id then
  local fg_win, _ = find_term_window(_G.foreground_terminal)
  if fg_win then
    -- Close the foreground terminal window (reveals target underneath)
    vim.api.nvim_win_close(fg_win, false)
    _G.foreground_terminal = term_id

    -- Focus the now-visible target terminal after a brief delay
    vim.defer_fn(function()
      local tw, _ = find_term_window(term_id)
      if tw then
        vim.api.nvim_set_current_win(tw)
        vim.cmd("startinsert")
      end
    end, 50)

    return false  -- Don't toggle, we already handled it
  end
end
```

**Case 4: Normal toggle**
```lua
-- No foreground terminal conflict, proceed normally
_G.foreground_terminal = term_id
return true  -- Proceed with toggle
```

### Integration with Terminal Mappings

Each terminal mapping follows this pattern:

```lua
map({ "n", "t" }, "<A-k>", function()
  local term = require "nvchad.term"

  -- Prepare: handle foreground terminal switching if needed
  local should_toggle = prepare_toggle("claude_term")

  -- Only toggle if prepare_toggle says we should
  if should_toggle then
    term.toggle {
      pos = "float",
      id = "claude_term",
      float_opts = {
        row = 0.02,
        col = 0.02,
        width = 0.85,
        height = 0.85,
        title = "Claude Code 🤖",
        title_pos = "center",
      }
    }
  end

  -- Auto-start logic (if first open)...
end, { desc = "terminal toggle claude code" })
```

## Key Technical Insights

### Why Buffer Tracking is Critical

NvChad's `term.toggle()` has specific behavior:
- When toggling a terminal closed, it **closes the window** but **keeps the buffer**
- When toggling the same terminal open again, it **recreates the window** from the existing buffer
- This preserves terminal state (history, running processes) without manual management

**Implication:**
- We can't rely solely on window existence to detect if a terminal exists
- Must check both window AND buffer existence
- This is why `find_term_buffer()` is essential for Case 1 detection

### The 50ms Delay

```lua
vim.defer_fn(function()
  -- Focus and enter insert mode
end, 50)
```

This delay is necessary because:
1. `vim.api.nvim_win_close()` is asynchronous
2. We need to wait for the foreground window to close before focusing the revealed terminal
3. 50ms is enough time for the window close operation to complete

### Terminal ID Patterns

Different terminals use different ID patterns:

**Simple IDs:**
- Claude: `"claude_term"`
- k9s: `"k9s_term"`
- Lazygit: `"lazygit_term"`

**Dynamic IDs (per-nvim-instance):**
- Tmux: `"floatTerm_" .. vim.fn.getpid()`
- This ensures each Neovim instance has its own unique tmux session

The `find_term_buffer()` function handles both patterns:
```lua
if buf_term_id == term_id or (buf_term_id and buf_term_id:match("^" .. term_id)) then
  -- Match exact term_id OR term_id pattern
end
```

## Failed Approaches (Historical Context)

### Attempt 1: Window Focus Only
```lua
vim.api.nvim_set_current_win(target_win)
```
**Result:** Terminal just toggled off
**Why it failed:** Didn't account for NvChad's toggle behavior

### Attempt 2: Z-index Manipulation
```lua
vim.api.nvim_win_set_config(win, { zindex = 50 })
```
**Result:** Didn't bring terminal to foreground
**Why it failed:** Neovim's floating window z-order is more complex

### Attempt 3: Close and Reopen
```lua
vim.api.nvim_win_close(target_win, false)
-- Then toggle to reopen
```
**Result:** User explicitly rejected this approach
**Why it failed:** Violated requirement to preserve terminal state without disruption

### Attempt 4: Hide All Other Terminals
```lua
-- Close all other floating terminals
```
**Result:** User explicitly rejected this approach
**Why it failed:** Violated requirement to maintain visual stack of terminals

### Final Success: Double-Toggle Pattern
The winning approach leverages NvChad's toggle behavior:
- Close foreground terminal (reveals hidden terminal underneath)
- Hidden terminal is now visible and focused
- No reopening needed, state preserved
- Visual stack maintained (other terminals still exist)

## Current Implementation Status

**Implemented (2 terminals):**
- ✅ Claude Code (ALT+k)
- ✅ Tmux (ALT+i)

**Pending (15 terminals):**
- k9s (ALT+j)
- Lazygit (ALT+h)
- OpenAI Codex (ALT+o)
- Browsh (ALT+b)
- Lazydocker (ALT+d)
- w3m (ALT+e)
- Carbonyl (ALT+c)
- e1s AWS ECS (ALT+1)
- e2s AWS EC2 (ALT+2)
- FZF All Commands (ALT+x)
- FZF Git Commands (ALT+Shift+G)
- FZF Docker Commands (ALT+Shift+D)
- FZF AWS Commands (ALT+Shift+A)
- FZF Aliases (ALT+Shift+X)
- FZF Homebrew (ALT+Shift+B)

## Testing Procedure

1. Open first terminal (e.g., ALT+k for Claude)
   - Should trigger: **Case 1** (Opening)

2. Open second terminal (e.g., ALT+i for tmux)
   - Should trigger: **Case 1** (Opening)
   - First terminal now hidden behind second

3. Press first terminal's shortcut (ALT+k)
   - Should trigger: **Case 3** (Revealing)
   - Second terminal should close
   - First terminal should be visible and focused

4. Press first terminal's shortcut again (ALT+k)
   - Should trigger: **Case 2** (Closing)
   - First terminal should close

## Debug Notifications

Temporary debug notifications are enabled to verify correct case detection:

```lua
vim.notify("Case 1: Opening " .. term_id, vim.log.levels.INFO)
vim.notify("Case 2: Closing " .. term_id, vim.log.levels.INFO)
vim.notify("Case 3: Hiding " .. fg_term .. ", revealing " .. term_id, vim.log.levels.WARN)
vim.notify("Case 4: Normal toggle " .. term_id, vim.log.levels.INFO)
```

**Remove these** once testing confirms all cases work correctly across all 17 terminals.

## Future Enhancements

1. **Cycle through stacked terminals** - ALT+Tab-like behavior to cycle through all open floating terminals
2. **Smart focus on auto-start** - When a terminal auto-starts a tool (k9s, Claude), ensure it becomes foreground
3. **Terminal history** - Track recently used terminals for quick switching
4. **Visual indicator** - Show which terminal is in foreground (status line, title bar)
5. **Persist across sessions** - Remember which terminals were open when exiting Neovim

## Related Files

- `nvim/.config/nvim/lua/mappings.lua` (lines 48-146) - Core implementation
- `CLAUDE.md` - Repository instructions for Claude Code
- `README.md` - User-facing documentation

## Key Learnings

1. **Buffer persistence** is more reliable than window existence for terminal state tracking
2. **User constraints** (don't close terminals, don't hide all) force creative solutions
3. **Async operations** require delays (50ms) for proper synchronization
4. **Debug notifications** are essential for understanding case flow in complex state machines
5. **Incremental rollout** (2 terminals first) validates approach before full implementation

## Success Criteria

- ✅ Terminal state preserved (no loss of CLI history or running processes)
- ✅ Visual stack maintained (other terminals remain open)
- ✅ Smart switching (hidden terminals revealed without double-pressing)
- ✅ Buffer-aware tracking (detects terminals even when windows closed)
- ⏳ All 17 terminals use the same `prepare_toggle()` pattern
- ⏳ Debug notifications removed
- ⏳ Tested across all terminal combinations
