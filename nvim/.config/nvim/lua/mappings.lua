require "nvchad.mappings"
local wk = require "which-key"
local map = vim.keymap.set

-- deprecated
-- map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>")
-- map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>")
-- map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>")
-- map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>")

map("n", "<C-h>", require("smart-splits").move_cursor_left)
map("n", "<C-j>", require("smart-splits").move_cursor_down)
map("n", "<C-k>", require("smart-splits").move_cursor_up)
map("n", "<C-l>", require("smart-splits").move_cursor_right)

-- ============================================================================
-- Terminal Scrolling: CTRL+q Handler
-- ============================================================================
-- Cache for tmux process checks (reduces system call overhead)
_G.tmux_check_cache = _G.tmux_check_cache or {}

-- Track the tmux terminal buffer number (since term_id isn't set reliably)
_G.tmux_terminal_buffer = _G.tmux_terminal_buffer or nil

-- Clean up tracking when tmux terminal buffer is deleted
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    if _G.tmux_terminal_buffer and args.buf == _G.tmux_terminal_buffer then
      _G.tmux_terminal_buffer = nil
    end
  end,
})

-- Check if tmux is actually running in this terminal job
-- Uses 500ms cache to avoid repeated system calls
local function is_tmux_alive(job_id)
  local now = vim.loop.now()
  local cache_entry = _G.tmux_check_cache[job_id]

  -- Return cached result if less than 500ms old
  if cache_entry and (now - cache_entry.time) < 500 then
    return cache_entry.alive
  end

  -- Check if tmux process exists as child of terminal
  local pid = vim.fn.jobpid(job_id)
  if not pid or pid == -1 then
    _G.tmux_check_cache[job_id] = { time = now, alive = false }
    return false
  end

  -- Use pgrep to find child processes, then check if any are tmux
  local output = vim.fn.system("pgrep -P " .. pid .. " | xargs ps -o comm= 2>/dev/null")
  local alive = output and output:match("tmux") ~= nil

  _G.tmux_check_cache[job_id] = { time = now, alive = alive }
  return alive
end

-- Terminal mode: CTRL+q for scrolling
-- Non-tmux terminals: Enter Neovim normal mode (same as NvChad's CTRL+x behavior)
-- Tmux terminal: Send CTRL+f [ to enter tmux copy-mode (native tmux scrolling)
map("t", "<C-q>", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local chan = vim.b[bufnr].terminal_job_id

  if not chan then
    vim.cmd("stopinsert")
    return
  end

  -- Hybrid approach: Buffer match + process check
  -- Step 1: Check if this buffer is the tracked tmux terminal buffer
  local is_tmux_terminal = (_G.tmux_terminal_buffer and bufnr == _G.tmux_terminal_buffer)

  if is_tmux_terminal then
    -- Step 2: Verify tmux is actually running (handles exit/crash/stale state)
    if is_tmux_alive(chan) then
      -- Tmux is alive: send CTRL+f [ (tmux's native copy-mode key sequence)
      -- This provides full scrollback buffer access with all tmux keybindings
      vim.api.nvim_chan_send(chan, "\x06[") -- \x06 is CTRL+f, then literal [
      return
    end
  end

  -- Default: enter Neovim normal mode for scrolling (NvChad default behavior)
  vim.cmd("stopinsert") -- Equivalent to <C-\><C-N>
end, { desc = "Terminal scrolling (tmux copy-mode or nvim normal mode)" })

vim.keymap.del({ "n", "t" }, "<A-v>")

-- ============================================================================
-- Foreground Terminal Tracking System
-- ============================================================================
-- Track which floating terminal is currently in the foreground
_G.foreground_terminal = nil
-- Track which terminal buffers have been created (persists even when window closes)
if not _G.terminal_buffers then
  _G.terminal_buffers = {}
end

-- Find a terminal window by term_id
-- Returns: window ID, buffer number (or nil, nil if not found)
local function find_term_window(term_id)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local buf_term_id = vim.b[buf].term_id
      -- Match exact term_id or term_id pattern (for tmux which has unique per-nvim-instance IDs)
      if buf_term_id == term_id or (buf_term_id and buf_term_id:match("^" .. term_id)) then
        return win, buf
      end
    end
  end
  return nil, nil
end

-- Check if a terminal buffer exists (even if window is closed)
-- Returns: buffer number or nil
local function find_term_buffer(term_id)
  -- First check if we have it tracked
  if _G.terminal_buffers[term_id] then
    local buf = _G.terminal_buffers[term_id]
    if vim.api.nvim_buf_is_valid(buf) then
      return buf
    else
      -- Buffer was deleted, clean up tracking
      _G.terminal_buffers[term_id] = nil
    end
  end

  -- Search all buffers as fallback
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local buf_term_id = vim.b[buf].term_id
      if buf_term_id == term_id or (buf_term_id and buf_term_id:match("^" .. term_id)) then
        _G.terminal_buffers[term_id] = buf
        return buf
      end
    end
  end
  return nil
end

-- Smart toggle: if target terminal exists but isn't foreground, hide foreground first
-- Returns: true if should proceed with toggle, false if already handled
local function prepare_toggle(term_id)
  local target_win, target_buf = find_term_window(term_id)

  -- If window doesn't exist, check if buffer exists
  if not target_buf then
    target_buf = find_term_buffer(term_id)
  end

  local current_buf = vim.api.nvim_get_current_buf()

  -- Case 1: Target terminal doesn't exist (neither window nor buffer) → Will open it
  if not target_win and not target_buf then
    _G.foreground_terminal = term_id
    return true  -- Proceed with toggle (opens it)
  end

  -- Case 2: Target terminal is already focused → Will close it
  if current_buf == target_buf then
    _G.foreground_terminal = nil
    return true  -- Proceed with toggle (closes it)
  end

  -- Case 3: Target terminal exists but isn't focused (hidden behind another terminal)
  -- Close the foreground terminal first to reveal the target
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

  -- Case 4: No foreground terminal conflict, proceed normally
  _G.foreground_terminal = term_id
  return true  -- Proceed with toggle
end

wk.add {
  {
    "<leader>e",
    ":NvimTreeFindFile<CR>",
    desc = "focus file",
  },
  {
    "<leader>ra",
    function()
      require "nvchad.lsp.renamer"()
    end,
    desc = "rename",
    icon = {
      icon = "",
      color = "yellow",
    },
  },
  {
    "<leader>D",
    vim.lsp.buf.type_definition,
    desc = "go to type definition",
    icon = {
      icon = "󰅩",
      color = "azure",
    },
  },
  {
    "gD",
    vim.lsp.buf.declaration,
    desc = "go to declaration",
    icon = {
      icon = "󰅩",
      color = "blue",
    },
  },
  {
    "gd",
    vim.lsp.buf.definition,
    desc = "go to definition",
    icon = {
      icon = "󰅩",
      color = "cyan",
    },
  },
  {
    "gi",
    vim.lsp.buf.implementation,
    desc = "go to implementation",
    icon = {
      icon = "󰆧",
      color = "cyan",
    },
  },
  {
    "<leader>S",
    ":GrugFar<CR>",
    desc = "search and replace",
    icon = {
      icon = "",
      color = "yellow",
    },
  },
  {
    "gC",
    ":tabnew<CR>",
    desc = "new tab",
    icon = {
      icon = "",
      color = "green",
    },
  },
  {
    "gt",
    ":tabnext<CR>",
    desc = "next tab",
    icon = {
      icon = "",
      color = "yellow",
    },
  },
  {
    "gT",
    ":tabprevious<CR>",
    desc = "previous tab",
    icon = {
      icon = "",
      color = "yellow",
    },
  },
  {
    "gX",
    ":tabclose<CR>",
    desc = "close tab",
    icon = {
      icon = "󰅖",
      color = "red",
    },
  },
  {
    "<leader>X",
    ":BufOnly<CR>",
    desc = "close all other buffers",
    icon = "󰟢",
  },
  {
    "<leader>cd",
    function()
      local actions = require "telescope.actions"
      local action_state = require "telescope.actions.state"
      require("telescope.builtin").find_files {
        prompt_title = " Change Working Directory",
        cwd = vim.fn.expand "~",
        find_command = {
          "fd",
          "--type", "d",
          "--hidden",
          "--max-depth", "5",
          "--exclude", ".git",
          "--exclude", "node_modules",
          "--exclude", ".next",
          "--exclude", "dist",
          "--exclude", "build",
          "--exclude", "out",
          "--exclude", "target",
          "--exclude", ".cache",
          "--exclude", ".npm",
          "--exclude", ".yarn",
          "--exclude", "Library",
          "--exclude", ".Trash",
          "--exclude", ".cargo",
          "--exclude", ".rustup",
          "--exclude", "venv",
          "--exclude", ".venv",
          "--exclude", "env",
          "--exclude", ".terraform",
          "--exclude", "*.app",
        },
        previewer = false,
        layout_strategy = "center",
        layout_config = {
          height = 0.4,
          width = 0.5,
          preview_cutoff = 1,
        },
        sorting_strategy = "ascending",
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if selection then
              local dir = selection.path or selection[1]
              vim.cmd("cd " .. vim.fn.fnameescape(dir))
              print(" Changed to: " .. dir)
            end
          end)
          return true
        end,
      }
    end,
    desc = "change directory (fuzzy)",
    icon = {
      icon = "",
      color = "azure",
    },
  },
  {
    mode = { "n", "v" }, -- NORMAL and VISUAL mode
    {
      "ga",
      vim.lsp.buf.code_action,
      desc = "code actions (LSP)",
      icon = {
        icon = "",
        color = "orange",
      },
      -- azure, blue, cyan, green, grey, orange, purple, red, yellow
    },
  },
  {
    "gpd",
    function()
      require("goto-preview").goto_preview_definition()
    end,
    desc = "preview definition",
    icon = {
      icon = "󰅩",
      color = "green",
    },
  },
  {
    "gpt",
    function()
      require("goto-preview").goto_preview_type_definition()
    end,
    desc = "preview type definition",
    icon = {
      icon = "󰊄",
      color = "green",
    },
  },
  {
    "gpi",
    function()
      require("goto-preview").goto_preview_implementation()
    end,
    desc = "preview implementation",
    icon = {
      icon = "󰆧",
      color = "green",
    },
  },
  {
    "gpD",
    function()
      require("goto-preview").goto_preview_declaration()
    end,
    desc = "preview declaration",
    icon = {
      icon = "󰀫",
      color = "green",
    },
  },
  {
    "gpr",
    function()
      require("goto-preview").goto_preview_references()
    end,
    desc = "preview references",
    icon = {
      icon = "󰈇",
      color = "green",
    },
  },
  {
    "gr",
    function()
      require("telescope.builtin").lsp_references()
    end,
    desc = "view references",
    icon = {
      icon = "󰈇",
      color = "green",
    },
  },
  {
    "gP",
    function()
      require("goto-preview").close_all_win()
    end,
    desc = "close preview",
    icon = "󰟢",
  },
  {
    mode = { "n", "v" }, -- NORMAL and VISUAL mode
    { "<leader>Q", "<cmd>qa<CR>", desc = "quit all", icon = "󰟢" },
    { "<leader>q", "<cmd>q<CR>", desc = "quit", icon = "󰟢" },
    { "<leader>w", "<cmd>w<CR>", desc = "write", icon = { icon = "", color = "green" } },
  },
  {
    "<leader>.",
    "@:",
    desc = "repeat last command",
    icon = {
      icon = "󰑖",
      color = "cyan",
    },
  },
  {
    "<leader><",
    function()
      require("smart-splits").resize_left(10)
    end,
    desc = "decrease width (repeatable)",
    icon = {
      icon = "󰼁",
      color = "blue",
    },
  },
  {
    "<leader>>",
    function()
      require("smart-splits").resize_right(10)
    end,
    desc = "increase width (repeatable)",
    icon = {
      icon = "󰼀",
      color = "blue",
    },
  },
  {
    "<leader>-",
    function()
      require("smart-splits").resize_down(5)
    end,
    desc = "decrease height (repeatable)",
    icon = {
      icon = "󰼃",
      color = "blue",
    },
  },
  {
    "<leader>+",
    function()
      require("smart-splits").resize_up(5)
    end,
    desc = "increase height (repeatable)",
    icon = {
      icon = "󰼂",
      color = "blue",
    },
  },
  {
    "<leader>tw",
    function()
      vim.wo.wrap = not vim.wo.wrap
    end,
    desc = "toggle word wrap",
    icon = {
      icon = "󰖶",
      color = "purple",
    },
  },
  {
    "<leader>mp",
    ":MarkdownPreviewToggle<CR>",
    desc = "toggle markdown preview",
    icon = {
      icon = "",
      color = "blue",
    },
  },
}

-- ============================================================================
-- Fuzzy Command Search Mappings (Alt+X and variants)
-- ============================================================================

-- Alt+Q: Fuzzy search all executables (floating terminal)
map({ "n", "t" }, "<A-q>", function()
  local term = require "nvchad.term"

  term.toggle {
    pos = "float",
    id = "fzf_all_commands",
    float_opts = {
      row = 0.05,
      col = 0.05,
      width = 0.9,
      height = 0.9,
      title = " 🔍 Command Search ",
      title_pos = "center",
    }
  }

  -- Auto-start the search on first open
  if not _G.fzf_all_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "fzf-command-widget\n")
          _G.fzf_all_started = true
        end
      end
    end, 200)
  end
end, { desc = "fuzzy search all commands" })

-- Alt+Shift+G: Git commands (floating terminal)
map({ "n", "t" }, "<A-G>", function()
  local term = require "nvchad.term"

  term.toggle {
    pos = "float",
    id = "fzf_git_commands",
    float_opts = {
      row = 0.06,
      col = 0.06,
      width = 0.9,
      height = 0.9,
      title = " 🔍 Git Commands ",
      title_pos = "center",
    }
  }

  if not _G.fzf_git_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "fzf-git-command-widget\n")
          _G.fzf_git_started = true
        end
      end
    end, 200)
  end
end, { desc = "fuzzy search git commands" })

-- Alt+Shift+D: Docker/K8s commands (floating terminal)
map({ "n", "t" }, "<A-D>", function()
  local term = require "nvchad.term"

  term.toggle {
    pos = "float",
    id = "fzf_docker_commands",
    float_opts = {
      row = 0.07,
      col = 0.07,
      width = 0.9,
      height = 0.9,
      title = " 🐳 Docker/K8s Commands ",
      title_pos = "center",
    }
  }

  if not _G.fzf_docker_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "fzf-docker-command-widget\n")
          _G.fzf_docker_started = true
        end
      end
    end, 200)
  end
end, { desc = "fuzzy search docker/k8s commands" })

-- Alt+Shift+A: AWS commands (floating terminal)
map({ "n", "t" }, "<A-A>", function()
  local term = require "nvchad.term"

  term.toggle {
    pos = "float",
    id = "fzf_aws_commands",
    float_opts = {
      row = 0.08,
      col = 0.08,
      width = 0.9,
      height = 0.9,
      title = " ☁️  AWS Commands ",
      title_pos = "center",
    }
  }

  if not _G.fzf_aws_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "fzf-aws-command-widget\n")
          _G.fzf_aws_started = true
        end
      end
    end, 200)
  end
end, { desc = "fuzzy search aws commands" })

-- Alt+Shift+X: Aliases and functions (floating terminal)
map({ "n", "t" }, "<A-X>", function()
  local term = require "nvchad.term"

  term.toggle {
    pos = "float",
    id = "fzf_aliases",
    float_opts = {
      row = 0.09,
      col = 0.09,
      width = 0.9,
      height = 0.9,
      title = " 🔧 Aliases & Functions ",
      title_pos = "center",
    }
  }

  if not _G.fzf_alias_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "fzf-alias-widget\n")
          _G.fzf_alias_started = true
        end
      end
    end, 200)
  end
end, { desc = "fuzzy search aliases and functions" })

-- Alt+Shift+B: Homebrew packages (floating terminal)
map({ "n", "t" }, "<A-B>", function()
  local term = require "nvchad.term"

  term.toggle {
    pos = "float",
    id = "fzf_brew",
    float_opts = {
      row = 0.10,
      col = 0.10,
      width = 0.9,
      height = 0.9,
      title = " 🍺 Homebrew Packages ",
      title_pos = "center",
    }
  }

  if not _G.fzf_brew_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "fzf-brew-widget\n")
          _G.fzf_brew_started = true
        end
      end
    end, 200)
  end
end, { desc = "fuzzy search homebrew packages" })

-- Track if we've started Claude in the terminal
_G.claude_started = false
_G.tmux_started = false

-- ALT+k toggles the Claude terminal and starts Claude on first open
map({ "n", "t" }, "<A-k>", function()
  local term = require "nvchad.term"

  -- Prepare: handle foreground terminal switching if needed
  local should_toggle = prepare_toggle("claude_term")

  -- Only toggle if prepare_toggle says we should (returns false if it already handled everything)
  if should_toggle then
    term.toggle {
      pos = "float",
      id = "claude_term",
      float_opts = {
        row = 0.02, -- ALT+k: Claude Code (top-left)
        col = 0.02,
        width = 0.85,
        height = 0.85,
        title = "Claude Code 🤖",
        title_pos = "center",
      }
    }
  end

  -- If this is the first time opening and we haven't started Claude yet
  if should_toggle and not _G.claude_started then
    -- Capture the buffer immediately after toggle (before defer_fn)
    local bufnr = vim.api.nvim_get_current_buf()
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions

      -- Check if we found the terminal buffer
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        -- Get the job_id from the buffer
        local success, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")

        if success and job_id then
          -- Interactive prompt: ask user whether to continue previous session or start fresh
          -- Write script to temp file, then execute it to ensure proper stdin/tty access
          local start_cmd = [[bash -c '
# Create a temp script with proper stdin access
cat > /tmp/claude_session_prompt_$$.sh << "SCRIPT_END"
#!/bin/bash

# Reopen stdin from the controlling terminal
exec < /dev/tty

if [ -d .claude ] && [ "$(ls -A .claude 2>/dev/null)" ]; then
  echo "📂 Previous Claude session detected in this directory"
  echo ""
  echo "Would you like to:"
  echo "  [c] Continue previous session"
  echo "  [f] Start fresh"
  echo ""

  # Read with proper terminal input
  read -r -p "Your choice (c/f): " choice
  echo ""

  case "$choice" in
    c|C)
      echo "▶ Continuing previous session..."
      sleep 0.2
      exec claude -c
      ;;
    f|F)
      echo "▶ Starting fresh session..."
      sleep 0.2
      exec claude
      ;;
    *)
      echo "▶ Invalid choice, starting fresh session..."
      sleep 0.2
      exec claude
      ;;
  esac
else
  clear
  exec claude
fi
SCRIPT_END

chmod +x /tmp/claude_session_prompt_$$.sh
exec /tmp/claude_session_prompt_$$.sh
']]
          vim.api.nvim_chan_send(job_id, "clear && " .. start_cmd .. "\n")
          _G.claude_started = true
        else
          vim.notify("Failed to get terminal job_id: " .. tostring(job_id), vim.log.levels.WARN)
        end
      else
        vim.notify("Current buffer is not a terminal: " .. vim.bo[bufnr].buftype, vim.log.levels.WARN)
      end
    end, 200)
  end
end, { desc = "terminal toggle claude code" })

-- ALT+i toggles the floating terminal and starts tmux on first open
-- Each nvim instance gets its own unique tmux session based on nvim PID
map({ "n", "t" }, "<A-i>", function()
  local term = require "nvchad.term"
  local nvim_pid = vim.fn.getpid()
  local term_id = "floatTerm_" .. nvim_pid

  -- Prepare: handle foreground terminal switching if needed
  local should_toggle = prepare_toggle(term_id)

  -- Only toggle if prepare_toggle says we should
  if should_toggle then
    term.toggle {
      pos = "float",
      id = term_id,
      float_opts = {
        row = 0.03, -- ALT+i: Tmux terminal
        col = 0.03,
        width = 0.85,
        height = 0.85,
        title = "multiflexing 💪",
        title_pos = "center",
      }
    }
  end

  -- Auto-start tmux on first open and track the buffer number
  if should_toggle and not _G.tmux_started then
    local session_name = "nvim_" .. nvim_pid  -- Capture in closure
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions

      -- Check if we found the terminal buffer
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        -- Track this buffer as the tmux terminal
        _G.tmux_terminal_buffer = bufnr

        -- Get the job_id from the buffer
        local success, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")

        if success and job_id then
          -- Use unique session name based on nvim PID (tmux -A creates or attaches)
          vim.api.nvim_chan_send(job_id, "tmux new-session -A -s " .. session_name .. "\n")
          _G.tmux_started = true
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle floating with tmux" })

-- ALT+j toggles the k9s terminal with cluster selection on first open
map({ "n", "t" }, "<A-j>", function()
  local term = require "nvchad.term"

  -- Prepare: handle foreground terminal switching if needed
  local should_toggle = prepare_toggle("k9s_term")

  -- Only toggle if prepare_toggle says we should
  if should_toggle then
    term.toggle {
      pos = "float",
      id = "k9s_term",
      float_opts = {
        row = 0.04, -- ALT+j: k9s
        col = 0.04,
        width = 0.85,
        height = 0.85,
        title = "k9s 🚀",
        title_pos = "center",
      }
    }
  end

  -- Track if k9s has been started
  if not _G.k9s_started then
    _G.k9s_started = false
  end

  -- If this is the first time opening and we haven't started k9s yet
  if should_toggle and not _G.k9s_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions

      -- Check if we found the terminal buffer
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        -- Get the job_id from the buffer
        local success, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")

        if success and job_id then
          -- Send command to select cluster with fzf, then select namespace, then launch k9s
          -- Clear terminal first for a clean interface
          -- Two-step selection: cluster -> namespace
          -- "all" option in namespace list uses -A flag for all namespaces
          local cmd = [[
clear && \
ctx=$(kubectl config get-contexts -o name | \
  fzf --height=40% --reverse --border \
      --prompt="Select K8s cluster: " \
      --preview="kubectl config get-contexts {}" \
      --preview-window=down:3:wrap) && \
if [ -n "$ctx" ]; then
  ns=$(echo -e "all\n$(kubectl --context "$ctx" get namespaces -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')" | \
    fzf --height=80% --reverse --border \
        --prompt="Select namespace ($ctx): " \
        --preview="if [ {} = 'all' ]; then echo 'View all namespaces'; else kubectl --context $ctx get pods -n {} 2>/dev/null | head -20; fi" \
        --preview-window=down:10:wrap)
  if [ -n "$ns" ]; then
    clear
    if [ "$ns" = "all" ]; then
      k9s --context "$ctx" -A
    else
      k9s --context "$ctx" -n "$ns"
    fi
  else
    echo "Namespace selection cancelled"
  fi
else
  echo "Cluster selection cancelled"
fi
]]
          vim.api.nvim_chan_send(job_id, cmd)
          _G.k9s_started = true
        else
          vim.notify("Failed to get terminal job_id: " .. tostring(job_id), vim.log.levels.WARN)
        end
      else
        vim.notify("Current buffer is not a terminal: " .. vim.bo[bufnr].buftype, vim.log.levels.WARN)
      end
    end, 200)
  end
end, { desc = "terminal toggle k9s with cluster selection" })

-- ALT+h toggles the lazygit terminal
map({ "n", "t" }, "<A-h>", function()
  local term = require "nvchad.term"

  -- Prepare: handle foreground terminal switching if needed
  local should_toggle = prepare_toggle("lazygit_term")

  -- Only toggle if prepare_toggle says we should
  if should_toggle then
    term.toggle {
      pos = "float",
      id = "lazygit_term",
      cmd = "lazygit",
      float_opts = {
        row = 0.05, -- ALT+h: Lazygit
        col = 0.05,
        width = 0.85,
        height = 0.85,
        title = "lazygit 🚀",
        title_pos = "center",
      }
    }
  end
end, { desc = "terminal toggle lazygit" })

-- ALT+o toggles the OpenAI CLI terminal
map({ "n", "t" }, "<A-o>", function()
  local term = require "nvchad.term"

  -- Prepare: handle foreground terminal switching if needed
  local should_toggle = prepare_toggle("openai_term")

  -- Only toggle if prepare_toggle says we should
  if should_toggle then
    term.toggle {
      pos = "float",
      id = "openai_term",
      float_opts = {
        row = 0.06, -- ALT+o: OpenAI CLI
        col = 0.06,
        width = 0.85,
        height = 0.85,
        title = "Codex CLI 🤖",
        title_pos = "center",
      }
    }
  end

  -- Track if OpenAI CLI has been started
  if not _G.openai_started then
    _G.openai_started = false
  end

  -- If this is the first time opening and we haven't started OpenAI yet
  if should_toggle and not _G.openai_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      -- Use the captured buffer to avoid race conditions

      -- Check if we found the terminal buffer
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        -- Get the job_id from the buffer
        local success, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")

        if success and job_id then
          vim.api.nvim_chan_send(job_id, "clear && codex\n")
          _G.openai_started = true
        else
          vim.notify("Failed to get terminal job_id: " .. tostring(job_id), vim.log.levels.WARN)
        end
      else
        vim.notify("Current buffer is not a terminal: " .. vim.bo[bufnr].buftype, vim.log.levels.WARN)
      end
    end, 200)
  end
end, { desc = "terminal toggle openai cli" })

-- ALT+d: Toggle lazydocker (Docker TUI)
map({ "n", "t" }, "<A-d>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "lazydockerTerm",
    float_opts = {
      row = 0.07, -- ALT+d: Lazydocker
      col = 0.07,
      width = 0.9,
      height = 0.9,
      border = "single",
      title = "  Lazydocker ",
      title_pos = "center",
    },
  }

  -- Auto-start lazydocker on first open
  if not _G.lazydocker_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      _G.lazydocker_started = true
      -- Use the captured buffer to avoid race conditions
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "lazydocker\n")
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle lazydocker" })

-- ALT+e: Toggle e1s (AWS ECS terminal UI) with profile/region selection
map({ "n", "t" }, "<A-e>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "e1sTerm",
    float_opts = {
      row = 0.09, -- ALT+e: e1s (AWS ECS)
      col = 0.09,
      width = 0.9,
      height = 0.9,
      border = "single",
      title = " 󰸏 e1s - AWS ECS ",
      title_pos = "center",
    },
  }

  -- Auto-start e1s with profile/region selection on first open
  if not _G.e1s_started then
    local bufnr = vim.api.nvim_get_current_buf()  -- Capture buffer immediately
    vim.defer_fn(function()
      _G.e1s_started = true
      -- Use the captured buffer to avoid race conditions
      if bufnr and vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          -- Two-step selection: AWS profile -> region
          local cmd = [[
clear && \
profile=$(aws configure list-profiles | \
  fzf --height=40% --reverse --border \
      --prompt="Select AWS Profile: " \
      --preview="aws configure list --profile {}" \
      --preview-window=down:5:wrap) && \
if [ -n "$profile" ]; then
  region=$(echo -e "us-east-1\nus-east-2\nus-west-1\nus-west-2\neu-west-1\neu-west-2\neu-west-3\neu-central-1\nap-northeast-1\nap-northeast-2\nap-southeast-1\nap-southeast-2\nap-south-1\nsa-east-1\nca-central-1" | \
    fzf --height=80% --reverse --border \
        --query="us-west-2" \
        --prompt="Select AWS Region ($profile): " \
        --preview="echo 'Profile: $profile\nRegion: {}'" \
        --preview-window=down:3:wrap)
  if [ -n "$region" ]; then
    clear
    AWS_PROFILE="$profile" AWS_REGION="$region" e1s
  else
    echo "Region selection cancelled"
  fi
else
  echo "Profile selection cancelled"
fi
]]
          vim.api.nvim_chan_send(chan, cmd)
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle e1s AWS ECS" })

-- ALT+u toggles the posting terminal (API client)
map({ "n", "t" }, "<A-u>", function()
  local term = require "nvchad.term"

  -- Prepare: handle foreground terminal switching if needed
  local should_toggle = prepare_toggle("posting_term")

  -- Only toggle if prepare_toggle says we should
  if should_toggle then
    term.toggle {
      pos = "float",
      id = "posting_term",
      cmd = "posting",
      float_opts = {
        row = 0.08, -- ALT+u: Posting API client
        col = 0.08,
        width = 0.85,
        height = 0.85,
        title = "Posting 📮",
        title_pos = "center",
      }
    }
  end
end, { desc = "terminal toggle posting API client" })

-- ALT+p closes and kills any floating terminal (ALT+i/k/j/h/o/d/e/u)
-- Note: When in terminal mode with apps like k9s running, press Ctrl+q first to exit terminal mode,
-- then press ALT+p. Or use this mapping which attempts to kill the process first.
map({ "n", "t" }, "<A-p>", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype == "terminal" then
    local nvim_pid = vim.fn.getpid()

    -- Kill tmux session if this is the tracked tmux terminal buffer
    if _G.tmux_terminal_buffer and bufnr == _G.tmux_terminal_buffer then
      local session_name = "nvim_" .. nvim_pid
      vim.fn.system("tmux kill-session -t " .. session_name .. " 2>/dev/null")
      _G.tmux_terminal_buffer = nil -- Clear tracked buffer
    end

    -- Try to stop the terminal job for other processes (k9s, openai, etc)
    local success, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")
    if success and job_id then
      vim.fn.jobstop(job_id)
    end

    -- Reset all terminal session tracking
    _G.claude_started = false
    _G.k9s_started = false
    _G.openai_started = false
    _G.lazydocker_started = false
    _G.e1s_started = false
    _G.e2s_started = false
    _G.fzf_all_started = false
    _G.fzf_git_started = false
    _G.fzf_docker_started = false
    _G.fzf_aws_started = false
    _G.fzf_alias_started = false
    _G.fzf_brew_started = false

    -- Delete the buffer (force = true to handle unsaved changes)
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end, { desc = "kill any floating terminal" })

-- Avante.nvim AI assistant keybindings
-- Using ALT+a for "Avante" to match the pattern of other tools (ALT+h, ALT+j, ALT+k, etc)
map({ "n", "v" }, "<A-a>", function()
  require("avante.api").ask()
end, { desc = "avante: ask" })

map({ "n", "v" }, "<leader>aa", function()
  require("avante.api").ask()
end, { desc = "avante: ask" })

map("n", "<leader>ar", function()
  require("avante.api").refresh()
end, { desc = "avante: refresh" })

map("v", "<leader>ae", function()
  require("avante.api").edit()
end, { desc = "avante: edit selection" })

map("n", "<leader>af", function()
  require("avante.api").focus()
end, { desc = "avante: focus sidebar" })

map("n", "<leader>at", function()
  require("avante").toggle()
end, { desc = "avante: toggle sidebar" })

-- macOS clipboard integration: CMD+v in visual mode
-- Pastes from clipboard and saves the replaced text back to clipboard
map("v", "<D-v>", function()
  -- Save what's currently in the clipboard (what we want to paste)
  local clipboard_content = vim.fn.getreg('+')
  -- Yank the visual selection to clipboard (temporarily)
  vim.cmd('normal! "+y')
  -- Save the selected text that we just yanked
  local selected_text = vim.fn.getreg('+')
  -- Restore the original clipboard content
  vim.fn.setreg('+', clipboard_content)
  -- Paste from clipboard (replaces the selection)
  vim.cmd('normal! gv"+p')
  -- Put the replaced text back into the clipboard
  vim.fn.setreg('+', selected_text)
end, { desc = "paste from clipboard, save replaced text to clipboard" })

-- macOS clipboard integration: Yank operations
-- Explicitly copy to system clipboard when yanking
-- Note: With clipboard=unnamedplus, these work automatically, but explicit mappings ensure clarity

-- Visual mode: yank to clipboard
map("v", "y", '"+y', { desc = "yank to clipboard" })

-- Normal mode: yank line to clipboard
map("n", "yy", '"+yy', { desc = "yank line to clipboard" })

-- Normal mode: yank motion to clipboard (e.g., yw, y$, yap)
map("n", "y", '"+y', { desc = "yank motion to clipboard" })

-- Visual mode: CMD+c to copy (macOS standard)
map("v", "<D-c>", '"+y', { desc = "copy to clipboard" })

-- Cleanup: Kill tmux session when Neovim exits
-- This prevents orphaned tmux sessions when closing wezterm tabs
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    local nvim_pid = vim.fn.getpid()
    local session_name = "nvim_" .. nvim_pid
    -- Kill tmux session silently (ignore errors if session doesn't exist)
    vim.fn.system("tmux kill-session -t " .. session_name .. " 2>/dev/null")
  end,
  desc = "Kill tmux session on Neovim exit"
})
