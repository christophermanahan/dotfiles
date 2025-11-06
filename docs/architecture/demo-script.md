# Paradiddle Quick Demo Script

**Duration:** 60 seconds
**Goal:** Show rapid terminal switching and workflow integration

---

## Preparation

1. Open Neovim in a real project directory
2. Have a simple file open (e.g., `README.md` or a code file)
3. Ensure all terminals are closed (`ALT+p` if needed)
4. Start recording

---

## Demo Script (60 seconds)

### Part 1: The Hook (10 seconds)

**Action:**
1. Show clean Neovim editor with code
2. Type comment: `// Need to check k8s pods`

**Say (or caption):**
> "10 CLI tools. 10 keystrokes. Zero friction."

---

### Part 2: Rapid Switching (30 seconds)

**Demo the rhythm - fast consecutive switches:**

**0:10** - Press `ALT+j`
- k9s appears with cluster selection
- Press ENTER on any cluster
- Press ENTER on any namespace
- k9s shows pods

**0:15** - Press `ALT+j` (k9s disappears)

**0:16** - Type in editor: `Fixed pod issue`

**0:18** - Press `ALT+h`
- Lazygit appears

**0:20** - In Lazygit:
- Press `s` (stage changes)
- Press `c` (commit)
- Type: "fix: k8s pod config"
- Press ENTER

**0:25** - Press `ALT+h` (Lazygit disappears)

**0:26** - Press `ALT+k`
- Claude Code appears

**0:28** - Type in Claude: "explain this fix"
- Let it start responding (just a few words)

**0:32** - Press `ALT+k` (Claude disappears)

**0:33** - Press `ALT+2`
- e2s appears

**0:35** - Press ESC to cancel (or quickly select a profile/region)

**0:37** - Press `ALT+p` (e2s disappears)

---

### Part 3: The Finale (20 seconds)

**Show all terminals cascading:**

**0:40** - Press these in rapid succession (1 second apart):
1. `ALT+k` - Claude appears (offset 0.02)
2. `ALT+i` - Tmux appears (offset 0.03)
3. `ALT+j` - k9s appears (offset 0.04)
4. `ALT+h` - Lazygit appears (offset 0.05)
5. `ALT+o` - Codex appears (offset 0.06)

**0:50** - Pause 2 seconds to show cascading windows

**0:52** - Press `ALT+p` five times quickly
- Watch all terminals disappear in reverse order

**0:57** - Back to clean editor

**Say (or caption):**
> "This is Paradiddle. github.com/christophermanahan/paradiddle"

---

## Alternative: 30-Second Version

If you want something even quicker:

### Ultra-Quick Demo (30 seconds)

**0:00** - Start in editor with text: "Checking production"

**0:03** - `ALT+j` → k9s appears → select cluster/namespace → see pods

**0:08** - `ALT+j` → k9s disappears

**0:09** - Type in editor: "Found the issue"

**0:11** - `ALT+h` → Lazygit → stage → commit

**0:16** - `ALT+h` → Lazygit disappears

**0:17** - `ALT+k` → Claude Code → type "explain this"

**0:22** - `ALT+k` → Claude disappears

**0:23** - `ALT+1` → e1s appears briefly

**0:25** - `ALT+p` → dismiss

**0:26** - Back to editor

**Caption:** "10 tools. 1 keystroke. Paradiddle."

---

## Tips for Screencap

### Recording Settings
- **Resolution:** 1920x1080 (or higher)
- **FPS:** 60fps (for smooth terminal animations)
- **Tool:** QuickTime (macOS) or OBS Studio

### Terminal Settings
```lua
-- In wezterm config, temporarily increase font size
font_size = 16  -- up from default 12
```

### Before Recording
1. Clear terminal history
2. Close notification apps
3. Enable Do Not Disturb
4. Set fixed screen resolution
5. Position windows for recording (centered, full-screen Neovim)

### Recording Tips
- **Count aloud:** "3... 2... 1... action"
- **Practice twice** before recording
- **Move deliberately** - not too fast, not too slow
- **Pause 1-2 seconds** after each major action
- **Keep cursor visible** - slow, deliberate movements

---

## Even Simpler: The "Flow State" Demo (15 seconds)

For social media clips (Twitter, etc.):

**0:00** - Show editor

**0:02** - `ALT+j` → k9s

**0:04** - `ALT+j` → back to editor

**0:06** - `ALT+h` → Lazygit

**0:08** - `ALT+h` → back to editor

**0:10** - `ALT+k` → Claude

**0:12** - `ALT+k` → back to editor

**0:13** - Type: "This is flow state."

**Caption on screen:**
```
10 terminals
10 keystrokes
0 friction

paradiddle
```

---

## What to Show vs What to Hide

### Show ✅
- Fast, confident keypresses
- Cascading window positions
- Clean, themed terminal (Catppuccin)
- Real workflows (not toy examples)
- The rhythm of switching

### Hide ❌
- Menu bars (use full-screen mode)
- Desktop clutter
- Slow loading times (edit those out)
- Mistakes/typos (do multiple takes)
- Personal information (git email, AWS accounts)

---

## Recording Checklist

**Before starting:**
- [ ] Clean Neovim config (no personal settings visible)
- [ ] Demo project with safe content
- [ ] Font size 16 for visibility
- [ ] Notifications disabled
- [ ] Practice run completed
- [ ] Recording software tested

**During recording:**
- [ ] Speak or use captions
- [ ] Count down before starting
- [ ] Move deliberately
- [ ] Pause between actions
- [ ] Show, don't tell

**After recording:**
- [ ] Trim beginning/end
- [ ] Add text overlays (optional)
- [ ] Export at 60fps
- [ ] Test on mobile device (is text readable?)

---

## Quick Editing in iMovie/Photos

If you just need a quick trim:

1. **Import** recording to Photos/iMovie
2. **Trim** start (first 2-3 seconds of you starting)
3. **Trim** end (last 2-3 seconds after demo)
4. **Add text** overlay at the end:
   ```
   Paradiddle - CLI First IDE
   github.com/christophermanahan/paradiddle
   ```
5. **Export** at original quality
6. **Share** to Twitter, Reddit, etc.

---

## Caption Ideas

For silent recordings with text overlays:

**Opening (3 seconds):**
```
10 CLI tools
Integrated into Neovim
Watch this
```

**During demo:**
```
ALT+j → k9s
ALT+h → Lazygit
ALT+k → Claude Code
ALT+2 → AWS EC2
```

**Closing:**
```
This is Paradiddle
CLI-first IDE
github.com/christophermanahan/paradiddle
```

---

## One-Take Wonder: The Absolute Simplest

If you want something you can nail in one take:

### 10-Second Demo

**Action:** Open Neovim, press these keys in sequence with 1.5 second pauses:
1. `ALT+k` (Claude appears)
2. `ALT+j` (k9s appears)
3. `ALT+h` (Lazygit appears)
4. `ALT+p` `ALT+p` `ALT+p` (all disappear)

**Caption:**
```
One keystroke per tool
No mouse
No menus
No friction

Paradiddle
```

**Record, trim, share.**

Done in 5 minutes.
