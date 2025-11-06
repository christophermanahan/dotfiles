# CLI Integration UI & LLM Context Sharing Plan

## Overview

Extend the CLI-first IDE to support:
1. **Dynamic CLI Configuration**: User-friendly UI for adding/configuring CLI tools with custom keybindings
2. **LLM Context Sharing**: Intelligent context synchronization between LLM-powered CLIs and the IDE

## Goals

- **Zero Configuration Barrier**: Add new CLI tools without editing Lua code
- **Intelligent Context**: LLM-powered CLIs maintain shared awareness of IDE state
- **Invisible Orchestration**: Context loading/saving happens automatically in background
- **Extensible Architecture**: Easy to add new LLM-powered tools

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Neovim IDE                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              CLI Configuration UI (TUI)                   │  │
│  │  - Add/Edit/Remove CLIs                                   │  │
│  │  - Configure Keybindings (ALT+key)                        │  │
│  │  - Mark as LLM-enabled                                    │  │
│  │  - Test CLI launch                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           Terminal Manager (Enhanced)                     │  │
│  │  - Dynamic keybinding registration                        │  │
│  │  - Hook: on_background → trigger context capture         │  │
│  │  - Hook: on_foreground → inject context load             │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────┬─────────────────────────────────────┬──┘
                         │                                     │
                         ↓                                     ↓
              ┌─────────────────────┐              ┌─────────────────────┐
              │  LLM Context Daemon │              │  Shared Context DB  │
              │  (Background)       │←────────────→│  ~/.nvim_context/   │
              │  - Monitor events   │              │  - context.json     │
              │  - Synthesize context│             │  - cli_states/      │
              │  - Update shared DB │              │  - ide_state.json   │
              └─────────────────────┘              └─────────────────────┘
                         ↑
                         │
                    ┌────┴─────┐
                    │ LLM API  │
                    │ (Claude) │
                    └──────────┘
```

---

## Component 1: CLI Configuration UI

### Design Approach: TUI (Terminal User Interface)

Use **Lua + NUI.nvim** for a native Neovim interface that fits the CLI-first philosophy.

### UI Structure

```
╔═══════════════════════════════════════════════════════════════╗
║  CLI Tool Manager                              [? Help] [q Quit] ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                ║
║  Configured CLIs (11)                                         ║
║  ┌────────────────────────────────────────────────────────┐  ║
║  │ ✓ ALT+k  │ Claude Code    │ 🤖 LLM  │ Auto-start      │  ║
║  │ ✓ ALT+i  │ Tmux           │         │ Auto-start      │  ║
║  │ ✓ ALT+j  │ k9s            │         │ Cluster select  │  ║
║  │ ✓ ALT+h  │ Lazygit        │         │ Standard        │  ║
║  │ ✓ ALT+o  │ Codex CLI      │ 🤖 LLM  │ Auto-start      │  ║
║  │ ✓ ALT+1  │ e1s (AWS ECS)  │         │ Profile select  │  ║
║  │ ✓ ALT+2  │ e2s (AWS EC2)  │         │ Instance select │  ║
║  │ ✓ ALT+a  │ Avante AI      │ 🤖 LLM  │ Sidebar mode    │  ║
║  │   ALT+3  │ <Add New CLI>  │         │                 │  ║
║  └────────────────────────────────────────────────────────┘  ║
║                                                                ║
║  [a] Add New  [e] Edit  [d] Delete  [t] Test Launch          ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
```

### Add/Edit CLI Dialog

```
╔═══════════════════════════════════════════════════════════════╗
║  Add New CLI Tool                                              ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                ║
║  Tool Name:        [____________________________________]      ║
║                                                                ║
║  Keybinding:       ALT+ [_]  (Available: 3,4,5,6,7,8,9,0)     ║
║                                                                ║
║  Launch Command:   [____________________________________]      ║
║                    Example: aider --model claude-3-5-sonnet   ║
║                                                                ║
║  Window Config:                                                ║
║    Title:          [____________________________________]      ║
║    Width:          [0.85] (0.1-1.0)                           ║
║    Height:         [0.85] (0.1-1.0)                           ║
║    Offset:         [0.13] (auto-calculated, editable)         ║
║                                                                ║
║  LLM Integration:  [ ] Enable LLM context sharing             ║
║    └─ Context Prompt: [View/Edit]                            ║
║                                                                ║
║  Auto-start:       [x] Launch command on first open           ║
║    └─ Startup delay: [200] ms                                ║
║                                                                ║
║  [Save]  [Test Launch]  [Cancel]                              ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
```

### Configuration File Format

**Location:** `~/.config/nvim/lua/cli_tools.json`

```json
{
  "version": "1.0",
  "tools": [
    {
      "id": "claude_code",
      "name": "Claude Code",
      "keybinding": "k",
      "command": "claude",
      "term_id": "claude_term",
      "window": {
        "title": "Claude Code 🤖",
        "width": 0.85,
        "height": 0.85,
        "offset": 0.02
      },
      "auto_start": {
        "enabled": true,
        "delay_ms": 200,
        "pre_command": "clear"
      },
      "llm_enabled": true,
      "llm_config": {
        "provider": "anthropic",
        "model": "claude-3-5-sonnet-20241022",
        "context_prompt": "Synthesize the conversation history from this CLI session with the current IDE context. Focus on: code changes discussed, files mentioned, decisions made, and next steps."
      }
    },
    {
      "id": "custom_aider",
      "name": "Aider",
      "keybinding": "3",
      "command": "aider --model claude-3-5-sonnet",
      "term_id": "aider_term",
      "window": {
        "title": "Aider 🤖",
        "width": 0.85,
        "height": 0.85,
        "offset": 0.13
      },
      "auto_start": {
        "enabled": true,
        "delay_ms": 200,
        "pre_command": "clear"
      },
      "llm_enabled": true,
      "llm_config": {
        "provider": "anthropic",
        "model": "claude-3-5-sonnet-20241022",
        "context_prompt": "Extract key information from this Aider session: what code was modified, what the user asked for, any errors encountered, and the current state of the conversation."
      }
    },
    {
      "id": "k9s",
      "name": "k9s",
      "keybinding": "j",
      "command": null,
      "term_id": "k9s_term",
      "window": {
        "title": "k9s 🚀",
        "width": 0.85,
        "height": 0.85,
        "offset": 0.04
      },
      "auto_start": {
        "enabled": true,
        "delay_ms": 200,
        "pre_command": "clear",
        "custom_script": "k9s_cluster_select.sh"
      },
      "llm_enabled": false
    }
  ],
  "settings": {
    "daemon_enabled": true,
    "daemon_port": 6767,
    "context_dir": "~/.nvim_context",
    "llm_provider": "anthropic",
    "llm_api_key_env": "ANTHROPIC_API_KEY"
  }
}
```

---

## Component 2: LLM Context Daemon

### Architecture

**Language:** Go (for performance, concurrency, easy daemon management)

**Location:** `~/.local/bin/nvim-context-daemon`

### Core Responsibilities

1. **Event Listener**: Unix socket server listening for events from Neovim
2. **Context Capture**: Extract terminal content when CLI goes to background
3. **Context Synthesis**: Use LLM to distill terminal state into structured context
4. **Context Storage**: Update shared context database
5. **Context Injection**: Prepare context for CLI when brought to foreground

### Daemon Implementation

```go
// Pseudo-code structure
package main

type ContextDaemon struct {
    config       Config
    contextDB    *ContextDB
    llmClient    *LLMClient
    eventServer  *EventServer
    ideWatcher   *IDEWatcher
}

type Event struct {
    Type      string  // "cli_background", "cli_foreground", "ide_file_change"
    CLIID     string  // "claude_code", "aider", etc.
    TermID    string  // Terminal buffer ID
    Content   string  // Terminal content (for background events)
    Timestamp int64
}

func (d *ContextDaemon) HandleCLIBackground(event Event) {
    // 1. Extract terminal content from event
    terminalContent := event.Content

    // 2. Get current IDE context
    ideContext := d.contextDB.GetIDEContext()

    // 3. Get tool config
    toolConfig := d.config.GetTool(event.CLIID)

    // 4. Synthesize with LLM
    synthesizedContext := d.llmClient.SynthesizeContext(
        terminalContent,
        ideContext,
        toolConfig.LLMConfig.ContextPrompt,
    )

    // 5. Update shared context
    d.contextDB.UpdateCLIContext(event.CLIID, synthesizedContext)

    log.Printf("Captured context for %s", event.CLIID)
}

func (d *ContextDaemon) HandleCLIForeground(event Event) {
    // 1. Get shared context for this CLI
    context := d.contextDB.GetContextForCLI(event.CLIID)

    // 2. Format context for injection
    contextText := d.formatContextForCLI(event.CLIID, context)

    // 3. Send context to Neovim for injection
    d.sendContextToNeovim(event.TermID, contextText)

    log.Printf("Injected context for %s", event.CLIID)
}

func (d *ContextDaemon) HandleIDEFileChange(event Event) {
    // Update IDE context when files change
    d.contextDB.UpdateIDEContext(event)
}
```

### Context Database Structure

**Location:** `~/.nvim_context/`

```
~/.nvim_context/
├── context.db              # SQLite database (alternative to JSON)
├── ide_state.json          # Current IDE state
├── cli_states/
│   ├── claude_code.json    # Last context from Claude Code
│   ├── aider.json          # Last context from Aider
│   └── codex.json          # Last context from Codex
└── shared_context.json     # Synthesized shared context
```

**ide_state.json** (Updated by Neovim):
```json
{
  "timestamp": 1704067200,
  "cwd": "/Users/cmanahan/projects/myapp",
  "current_file": "src/api/handler.ts",
  "open_files": [
    "src/api/handler.ts",
    "src/models/user.ts",
    "tests/api.test.ts"
  ],
  "git_branch": "feature/auth-refactor",
  "recent_changes": [
    {
      "file": "src/api/handler.ts",
      "timestamp": 1704067100,
      "summary": "Modified authentication middleware"
    }
  ],
  "lsp_diagnostics": {
    "errors": 2,
    "warnings": 5,
    "files": ["src/api/handler.ts", "src/utils/jwt.ts"]
  }
}
```

**claude_code.json** (Managed by daemon):
```json
{
  "cli_id": "claude_code",
  "last_active": 1704067200,
  "session_duration": 1800,
  "context": {
    "summary": "User is refactoring authentication middleware in src/api/handler.ts. Discussed moving JWT verification to a separate utility. Identified 2 type errors that need fixing. Next step: extract JWT logic to src/utils/jwt.ts",
    "key_files": [
      "src/api/handler.ts",
      "src/utils/jwt.ts"
    ],
    "decisions": [
      "Move JWT verification to separate utility",
      "Use dependency injection for auth middleware"
    ],
    "pending_tasks": [
      "Fix type errors in handler.ts",
      "Create JWT utility module",
      "Update tests"
    ],
    "code_snippets": [
      {
        "description": "JWT verification function to extract",
        "code": "const verifyToken = (token: string) => jwt.verify(token, SECRET);"
      }
    ]
  },
  "raw_transcript": "..." // Optional: full conversation history
}
```

**shared_context.json** (Synthesized from all sources):
```json
{
  "timestamp": 1704067200,
  "project": {
    "path": "/Users/cmanahan/projects/myapp",
    "branch": "feature/auth-refactor"
  },
  "current_focus": "Refactoring authentication middleware",
  "active_files": [
    "src/api/handler.ts",
    "src/utils/jwt.ts",
    "tests/api.test.ts"
  ],
  "recent_activity": {
    "claude_code": "Discussed JWT refactoring strategy, identified type errors",
    "ide": "Modified handler.ts, opened jwt.ts",
    "aider": null
  },
  "pending_tasks": [
    "Fix type errors in handler.ts (priority: high)",
    "Extract JWT logic to utils",
    "Update authentication tests"
  ],
  "decisions_made": [
    "Use dependency injection for middleware",
    "Separate JWT verification into utility module"
  ]
}
```

---

## Component 3: Enhanced Terminal Manager (Neovim Lua)

### Terminal Manager API

**File:** `~/.config/nvim/lua/terminal_manager.lua`

```lua
local M = {}
local config = require("cli_config_loader")
local daemon_client = require("daemon_client")

-- Load CLI configuration from JSON
M.cli_tools = config.load()

-- Track active CLI states
M.cli_states = {}

-- Register keybindings dynamically
function M.setup()
  for _, tool in ipairs(M.cli_tools.tools) do
    M.register_cli(tool)
  end

  -- Start daemon if enabled
  if M.cli_tools.settings.daemon_enabled then
    daemon_client.ensure_running()
  end
end

function M.register_cli(tool)
  local map = vim.keymap.set

  map({ "n", "t" }, "<A-" .. tool.keybinding .. ">", function()
    M.toggle_cli(tool)
  end, { desc = "terminal toggle " .. tool.name })
end

function M.toggle_cli(tool)
  local term = require("nvchad.term")
  local is_visible = M.is_cli_visible(tool.term_id)

  -- Notify daemon: CLI going to background
  if is_visible and tool.llm_enabled then
    local content = M.capture_terminal_content(tool.term_id)
    daemon_client.send_event({
      type = "cli_background",
      cli_id = tool.id,
      term_id = tool.term_id,
      content = content,
      timestamp = os.time()
    })
  end

  -- Toggle terminal
  term.toggle({
    pos = "float",
    id = tool.term_id,
    float_opts = {
      row = tool.window.offset,
      col = tool.window.offset,
      width = tool.window.width,
      height = tool.window.height,
      title = tool.window.title,
      title_pos = "center",
    }
  })

  -- Handle auto-start
  if not M.cli_states[tool.id] and tool.auto_start.enabled then
    M.auto_start_cli(tool)
  end

  -- Notify daemon: CLI coming to foreground
  if not is_visible and tool.llm_enabled then
    daemon_client.send_event({
      type = "cli_foreground",
      cli_id = tool.id,
      term_id = tool.term_id,
      timestamp = os.time()
    })

    -- Wait for context, then inject invisibly
    vim.defer_fn(function()
      M.inject_context(tool)
    end, 300)
  end
end

function M.inject_context(tool)
  -- Receive context from daemon
  local context = daemon_client.get_context_for_cli(tool.id)

  if not context then return end

  -- Format context as invisible command or special input
  -- For Claude Code / Aider: send as system message or file
  -- For other CLIs: might skip or use different mechanism

  local bufnr = M.get_terminal_buffer(tool.term_id)
  if not bufnr then return end

  local job_id = vim.b[bufnr].terminal_job_id
  if not job_id then return end

  -- Option 1: Write to temp file and pass as argument
  local context_file = vim.fn.tempname() .. ".context.md"
  local f = io.open(context_file, "w")
  f:write("# IDE Context\n\n")
  f:write(context.summary .. "\n\n")
  f:write("## Current Focus\n" .. context.current_focus .. "\n\n")
  f:write("## Pending Tasks\n")
  for _, task in ipairs(context.pending_tasks) do
    f:write("- " .. task .. "\n")
  end
  f:close()

  -- For Claude Code: use /add command to ingest context
  vim.api.nvim_chan_send(job_id, "/add " .. context_file .. "\n")

  -- Clean up context file after brief delay
  vim.defer_fn(function()
    os.remove(context_file)
  end, 5000)
end

function M.capture_terminal_content(term_id)
  local bufnr = M.get_terminal_buffer(term_id)
  if not bufnr then return "" end

  -- Get last 500 lines of terminal content
  local lines = vim.api.nvim_buf_get_lines(bufnr, -500, -1, false)
  return table.concat(lines, "\n")
end

-- Watch IDE changes and notify daemon
function M.watch_ide_changes()
  vim.api.nvim_create_autocmd({"BufWritePost", "BufEnter"}, {
    callback = function(ev)
      daemon_client.send_event({
        type = "ide_file_change",
        file = ev.file,
        timestamp = os.time()
      })
    end
  })
end

return M
```

---

## Component 4: CLI Configuration UI (Neovim TUI)

**File:** `~/.config/nvim/lua/cli_config_ui.lua`

```lua
local M = {}
local Popup = require("nui.popup")
local Menu = require("nui.menu")
local Input = require("nui.input")

function M.open()
  local config = require("cli_config_loader").load()

  -- Create main menu
  local menu_items = {}

  for _, tool in ipairs(config.tools) do
    local llm_indicator = tool.llm_enabled and "🤖 LLM" or "    "
    local label = string.format(
      "ALT+%s  │ %-20s │ %s │ %s",
      tool.keybinding,
      tool.name,
      llm_indicator,
      tool.auto_start.enabled and "Auto-start" or "Manual"
    )
    table.insert(menu_items, Menu.item(label, { tool = tool }))
  end

  -- Add "Add New" option
  table.insert(menu_items, Menu.separator())
  table.insert(menu_items, Menu.item("+ Add New CLI Tool", { action = "add" }))

  local menu = Menu({
    position = "50%",
    size = { width = 80, height = 20 },
    border = {
      style = "rounded",
      text = { top = " CLI Tool Manager ", top_align = "center" }
    }
  }, {
    lines = menu_items,
    keymap = {
      focus_next = { "j", "<Down>" },
      focus_prev = { "k", "<Up>" },
      close = { "<Esc>", "q" },
      submit = { "<CR>", "<Space>" }
    },
    on_submit = function(item)
      if item.action == "add" then
        M.show_add_dialog()
      else
        M.show_edit_dialog(item.tool)
      end
    end
  })

  menu:mount()
end

function M.show_add_dialog()
  -- Create form with NUI inputs
  local form_data = {
    name = "",
    keybinding = "",
    command = "",
    llm_enabled = false
  }

  -- Show popup with form fields
  -- (Implementation details using nui.input components)

  -- On save: write to cli_tools.json and reload config
end

function M.show_edit_dialog(tool)
  -- Similar to add_dialog but pre-populated with tool data
end

-- Register command to open UI
vim.api.nvim_create_user_command("CLIToolsConfig", function()
  M.open()
end, {})

-- Add keybinding
vim.keymap.set("n", "<leader>ct", function()
  M.open()
end, { desc = "Configure CLI tools" })

return M
```

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
**Goal:** Configuration system and dynamic keybinding registration

- [x] Create JSON configuration schema
- [ ] Implement `cli_config_loader.lua` to parse JSON
- [ ] Refactor existing terminal mappings to use configuration
- [ ] Test dynamic keybinding registration
- [ ] Migrate existing 11 CLIs to JSON format

**Deliverable:** All existing CLIs work via JSON configuration

### Phase 2: Configuration UI (Week 3)
**Goal:** User-friendly TUI for managing CLIs

- [ ] Design TUI layout with NUI.nvim
- [ ] Implement CLI list view
- [ ] Implement add/edit dialogs
- [ ] Add validation for keybindings (prevent conflicts)
- [ ] Add "Test Launch" functionality
- [ ] Create `:CLIToolsConfig` command

**Deliverable:** Users can add/edit/remove CLIs without editing Lua code

### Phase 3: Context Daemon - Core (Week 4-5)
**Goal:** Background daemon with event processing

- [ ] Create Go daemon project structure
- [ ] Implement Unix socket event server
- [ ] Create Neovim client for sending events
- [ ] Implement IDE state watcher (file changes, LSP diagnostics)
- [ ] Create context database structure
- [ ] Test event flow: Neovim → Daemon → Storage

**Deliverable:** Daemon captures terminal content and IDE state

### Phase 4: LLM Integration (Week 6-7)
**Goal:** Intelligent context synthesis

- [ ] Implement Anthropic API client in daemon
- [ ] Create context synthesis prompts
- [ ] Test context extraction from Claude Code sessions
- [ ] Implement context formatting for different CLI types
- [ ] Add context injection logic
- [ ] Test round-trip: background → synthesize → foreground

**Deliverable:** Claude Code sessions maintain context awareness

### Phase 5: Multi-CLI Context Sharing (Week 8)
**Goal:** Multiple LLM CLIs share context

- [ ] Implement shared context aggregation
- [ ] Test context flow: Claude Code → Aider
- [ ] Add conflict resolution (overlapping context)
- [ ] Implement context pruning (prevent bloat)
- [ ] Add context versioning

**Deliverable:** Multiple LLM tools work on same task with shared context

### Phase 6: Polish & Optimization (Week 9-10)
**Goal:** Production-ready system

- [ ] Add error handling and recovery
- [ ] Implement daemon auto-start with Neovim
- [ ] Add logging and debugging tools
- [ ] Create context visualization UI
- [ ] Performance optimization (reduce LLM calls)
- [ ] Write documentation
- [ ] Create example configurations

**Deliverable:** Stable, documented system ready for daily use

---

## Technical Considerations

### 1. Context Capture Challenges

**Problem:** Terminal scrollback buffer has limited history
**Solution:**
- Capture on periodic intervals (every 30s) in addition to background events
- Store incremental diffs rather than full content
- Use terminal multiplexers (tmux) for better history

**Problem:** Sensitive data in terminal (API keys, passwords)
**Solution:**
- Add content filtering before sending to LLM
- Regex patterns to redact common secrets
- User-configurable redaction rules

### 2. LLM API Costs

**Problem:** Context synthesis on every background event could be expensive
**Solution:**
- Debouncing: only synthesize after 30s of inactivity
- Incremental updates: only synthesize new content
- Local model option: Ollama for lightweight synthesis
- User-configurable: disable for non-critical CLIs

### 3. Context Injection Methods

Different CLIs need different injection strategies:

| CLI Type | Injection Method | Example |
|----------|------------------|---------|
| Claude Code | `/add` command + context file | `/add /tmp/context.md` |
| Aider | `--read` flag on startup | `aider --read /tmp/context.md` |
| Generic LLM | Prepend to first prompt | `# Context:\n...` |
| Non-LLM | Skip injection | N/A |

### 4. Daemon Management

**Start daemon automatically:**
```lua
-- In init.lua
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.fn.system("~/.local/bin/nvim-context-daemon start")
  end
})
```

**Stop daemon on exit:**
```lua
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    -- Send shutdown signal (daemon continues in background)
    require("daemon_client").send_event({ type = "neovim_exit" })
  end
})
```

### 5. Security & Privacy

- **Local-first:** All context stored locally by default
- **Opt-in LLM:** Users must explicitly enable LLM features
- **API key security:** Never store API keys in context DB
- **Redaction:** Automatic filtering of common secret patterns
- **User control:** Easy way to view/delete stored context

---

## Example Workflows

### Workflow 1: Adding a New LLM Tool (Aider)

1. **User opens config UI:**
   ```
   :CLIToolsConfig
   ```

2. **User presses 'a' to add new tool:**
   - Name: `Aider`
   - Keybinding: `3`
   - Command: `aider --model claude-3-5-sonnet`
   - Enable LLM: `✓`
   - Auto-start: `✓`

3. **User presses 's' to save**

4. **Config is written to JSON:**
   ```json
   {
     "id": "aider",
     "name": "Aider",
     "keybinding": "3",
     "command": "aider --model claude-3-5-sonnet",
     "llm_enabled": true,
     ...
   }
   ```

5. **Keybinding is registered immediately:**
   - ALT+3 now launches Aider
   - No Neovim restart needed

### Workflow 2: LLM Context Flow

**Scenario:** User switches between Claude Code and Aider for same task

1. **User working in Claude Code (ALT+k):**
   ```
   User: Help me refactor this authentication handler
   Claude: [discusses JWT strategy, suggests extracting utility]
   User: [makes changes to handler.ts]
   ```

2. **User sends Claude to background:**
   - Presses ALT+k to hide
   - **Daemon captures terminal content**
   - **LLM synthesizes context:**
     ```
     Summary: Refactoring auth handler, extracting JWT logic
     Key files: handler.ts, jwt.ts (to be created)
     Next steps: Create JWT utility, fix type errors
     ```

3. **User opens Aider (ALT+3):**
   - **Daemon detects foreground event**
   - **Retrieves synthesized context**
   - **Injects context invisibly:**
     ```bash
     # Behind the scenes:
     aider --read /tmp/.nvim_context_123.md
     ```
   - **User sees Aider ready with context:**
     ```
     Aider> I see you're working on refactoring authentication.
     Ready to help extract the JWT utility.
     ```

4. **User continues work in Aider:**
   ```
   User: Create the JWT utility module
   Aider: [creates src/utils/jwt.ts]
   ```

5. **User returns to Claude Code (ALT+k):**
   - **Aider context is captured and synthesized**
   - **Claude receives updated context**
   - **Claude knows JWT utility was created**

**Result:** Seamless handoff between LLM tools with no manual context copying

### Workflow 3: Context Visualization

**User wants to see what context is being shared:**

```
:CLIContextView
```

**UI shows:**
```
╔═══════════════════════════════════════════════════════════════╗
║  Shared Context Viewer                                         ║
╠═══════════════════════════════════════════════════════════════╣
║  Project: /Users/cmanahan/projects/myapp                      ║
║  Branch: feature/auth-refactor                                 ║
║  Focus: Refactoring authentication middleware                  ║
║                                                                 ║
║  Active Files:                                                  ║
║    • src/api/handler.ts (modified 2m ago)                      ║
║    • src/utils/jwt.ts (created 1m ago)                         ║
║                                                                 ║
║  Recent Activity:                                               ║
║    🤖 Claude Code (5m ago):                                     ║
║       Discussed JWT extraction strategy                         ║
║    🤖 Aider (2m ago):                                           ║
║       Created JWT utility module                                ║
║                                                                 ║
║  Pending Tasks:                                                 ║
║    • Fix type errors in handler.ts                             ║
║    • Update authentication tests                                ║
║                                                                 ║
║  [r] Refresh  [c] Clear Context  [e] Export  [q] Quit         ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Future Enhancements

### 1. Cross-Machine Context Sync
- Sync context to cloud (encrypted)
- Work on laptop → continue on desktop with same context

### 2. Team Context Sharing
- Share synthesized context with team members
- "Claude Code sessions" as shareable artifacts

### 3. Context-Aware Code Actions
- LSP integration: suggest actions based on LLM discussions
- Example: "Claude suggested extracting this function" → show as code action

### 4. Voice Integration
- Voice input/output for LLM CLIs
- Hands-free coding sessions

### 5. Context Analytics
- Visualize coding patterns over time
- "You spent 80% of time on auth refactoring"
- Identify recurring discussion topics

---

## Success Metrics

1. **User Adoption:** Users add at least 2 custom CLIs within first week
2. **Context Quality:** LLM tools maintain >90% relevant context on handoff
3. **Performance:** Context injection adds <300ms latency
4. **Reliability:** Daemon uptime >99.5%
5. **User Satisfaction:** "Context sharing feels magical" feedback

---

## Appendix: Alternative Designs Considered

### Alternative 1: No Daemon (Neovim-Only)
**Pros:** Simpler, no external process
**Cons:** Neovim blocks on LLM calls, harder to manage state

### Alternative 2: Context in Git
**Pros:** Version controlled, shareable
**Cons:** Pollutes git history, slow

### Alternative 3: Cloud-Based Context Service
**Pros:** Sync across machines, team sharing
**Cons:** Privacy concerns, requires internet, latency

**Decision:** Local daemon provides best balance of performance, privacy, and extensibility.
