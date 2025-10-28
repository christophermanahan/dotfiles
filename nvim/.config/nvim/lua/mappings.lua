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

-- Terminal mode: Ctrl+q to enter normal mode (allows scrolling in floating terminals)
-- Note: We don't use Ctrl+[ or ESC because:
-- - Ctrl+[ is identical to ESC at terminal level, would break ZSH vi-mode ESC
-- - ESC should pass through to the shell for vi-mode
-- Ctrl+q is rarely used and doesn't conflict with terminal applications
-- SMART BEHAVIOR: If tmux is running, send CTRL+q to tmux (it has bind -n C-q copy-mode)
map("t", "<C-q>", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local chan = vim.b[bufnr].terminal_job_id

  if chan then
    -- Check if tmux is running by looking at the global tracking variable
    -- The tmux terminal is tracked as floatTerm_<nvim_pid>
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

vim.keymap.del({ "n", "t" }, "<A-v>")

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

-- Alt+X: Fuzzy search all executables (floating terminal)
map({ "n", "t" }, "<A-x>", function()
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
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
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
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
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
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
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
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
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
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
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
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
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

  -- If this is the first time opening and we haven't started Claude yet
  if not _G.claude_started then
    vim.defer_fn(function()
      -- After toggle, the terminal should be the current buffer
      local bufnr = vim.api.nvim_get_current_buf()

      -- Check if it's a terminal buffer
      if vim.bo[bufnr].buftype == "terminal" then
        -- Get the job_id from the buffer
        local success, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")

        if success and job_id then
          vim.api.nvim_chan_send(job_id, "clear && claude\n")
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

  -- Track if tmux has been started for this specific terminal instance
  if not _G.tmux_sessions then
    _G.tmux_sessions = {}
  end

  -- If this is the first time opening and we haven't started tmux for this instance yet
  if not _G.tmux_sessions[term_id] then
    vim.defer_fn(function()
      -- After toggle, the terminal should be the current buffer
      local bufnr = vim.api.nvim_get_current_buf()

      -- Check if it's a terminal buffer
      if vim.bo[bufnr].buftype == "terminal" then
        -- Get the job_id from the buffer
        local success, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")

        if success and job_id then
          -- Use unique session name based on nvim PID
          local session_name = "nvim_" .. nvim_pid
          vim.api.nvim_chan_send(job_id, "tmux new-session -A -s " .. session_name .. "\n")
          _G.tmux_sessions[term_id] = true
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle floating with tmux" })

-- ALT+j toggles the k9s terminal with cluster selection on first open
map({ "n", "t" }, "<A-j>", function()
  local term = require "nvchad.term"

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

  -- Track if k9s has been started
  if not _G.k9s_started then
    _G.k9s_started = false
  end

  -- If this is the first time opening and we haven't started k9s yet
  if not _G.k9s_started then
    vim.defer_fn(function()
      -- After toggle, the terminal should be the current buffer
      local bufnr = vim.api.nvim_get_current_buf()

      -- Check if it's a terminal buffer
      if vim.bo[bufnr].buftype == "terminal" then
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
end, { desc = "terminal toggle lazygit" })

-- ALT+o toggles the OpenAI CLI terminal
map({ "n", "t" }, "<A-o>", function()
  local term = require "nvchad.term"

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

  -- Track if OpenAI CLI has been started
  if not _G.openai_started then
    _G.openai_started = false
  end

  -- If this is the first time opening and we haven't started OpenAI yet
  if not _G.openai_started then
    vim.defer_fn(function()
      -- After toggle, the terminal should be the current buffer
      local bufnr = vim.api.nvim_get_current_buf()

      -- Check if it's a terminal buffer
      if vim.bo[bufnr].buftype == "terminal" then
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

-- ALT+b: Toggle browsh (terminal web browser)
map({ "n", "t" }, "<A-b>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "browshTerm",
    float_opts = {
      row = 0.07, -- ALT+b: Browsh browser (larger window)
      col = 0.07,
      width = 0.84,
      height = 0.84,
      border = "single",
      title = " 󰖟 Browsh Browser ",
      title_pos = "center",
    },
  }

  -- Auto-start browsh on first open
  if not _G.browsh_started then
    vim.defer_fn(function()
      _G.browsh_started = true
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "browsh\n")
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle browsh browser" })

-- ALT+d: Toggle lazydocker (Docker TUI)
map({ "n", "t" }, "<A-d>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "lazydockerTerm",
    float_opts = {
      row = 0.08, -- ALT+d: Lazydocker (large window)
      col = 0.08,
      width = 0.9,
      height = 0.9,
      border = "single",
      title = "  Lazydocker ",
      title_pos = "center",
    },
  }

  -- Auto-start lazydocker on first open
  if not _G.lazydocker_started then
    vim.defer_fn(function()
      _G.lazydocker_started = true
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "lazydocker\n")
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle lazydocker" })

-- ALT+e: Toggle w3m terminal (opens DuckDuckGo Lite by default)
map({ "n", "t" }, "<A-e>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "w3mTerm",
    float_opts = {
      row = 0.09,
      col = 0.09,
      width = 0.85,
      height = 0.85,
      border = "single",
      title = " 󰖟 w3m Browser (vim keys) ",
      title_pos = "center",
    },
  }

  -- Auto-start w3m with DuckDuckGo Lite on first open
  if not _G.w3m_started then
    vim.defer_fn(function()
      _G.w3m_started = true
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "w3m 'https://lite.duckduckgo.com/lite/'\n")
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle w3m" })

-- ALT+s: Search in w3m (prompts for query, opens or navigates w3m)
map({ "n", "t" }, "<A-s>", function()
  -- Use a centered input box with dressing.nvim styling
  vim.ui.input({
    prompt = "🔍 DuckDuckGo Search: ",
    default = "",
    -- Dressing.nvim will handle the centered layout based on config
  }, function(query)
    if not query or query == "" then
      return -- User cancelled
    end

    -- Encode the search query for URL
    local encoded_query = query:gsub(" ", "+")
    local search_url = "https://lite.duckduckgo.com/lite/?q=" .. encoded_query

    -- Find the w3m terminal buffer and check if it's visible
    local w3m_bufnr = nil
    local w3m_visible = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
        local term_id = vim.b[buf].term_id
        if term_id == "w3mTerm" then
          w3m_bufnr = buf
          -- Check if this buffer is visible in any window
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == buf then
              w3m_visible = true
              break
            end
          end
          break
        end
      end
    end

    if w3m_bufnr and w3m_visible then
      -- w3m is open and visible, send new search
      local chan = vim.b[w3m_bufnr].terminal_job_id
      if chan then
        vim.api.nvim_chan_send(chan, "w3m '" .. search_url .. "'\n")
      end
    else
      -- w3m not visible, open it with the search
      _G.w3m_started = true
      require("nvchad.term").toggle {
        pos = "float",
        id = "w3mTerm",
        float_opts = {
          row = 0.09,
          col = 0.09,
          width = 0.85,
          height = 0.85,
          border = "single",
          title = " 󰖟 w3m Browser (vim keys) ",
          title_pos = "center",
        },
      }

      -- Start w3m with the search query
      vim.defer_fn(function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.bo[bufnr].buftype == "terminal" then
          local chan = vim.b[bufnr].terminal_job_id
          if chan then
            vim.api.nvim_chan_send(chan, "w3m '" .. search_url .. "'\n")
          end
        end
      end, 200)
    end
  end)
end, { desc = "w3m search" })

-- ALT+c: Toggle carbonyl (cutting-edge Chromium browser)
map({ "n", "t" }, "<A-c>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "carbonylTerm",
    float_opts = {
      row = 0.10, -- ALT+c: Carbonyl browser
      col = 0.10,
      width = 0.88,
      height = 0.88,
      border = "single",
      title = " 󰈹 Carbonyl Browser (Chromium) ",
      title_pos = "center",
    },
  }

  -- Auto-start carbonyl on first open with ChatGPT
  if not _G.carbonyl_started then
    vim.defer_fn(function()
      _G.carbonyl_started = true
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "carbonyl https://chatgpt.com\n")
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle carbonyl browser" })

-- ALT+1: Toggle e1s (AWS ECS terminal UI) with profile/region selection
map({ "n", "t" }, "<A-1>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "e1sTerm",
    float_opts = {
      row = 0.11, -- ALT+1: e1s (AWS ECS)
      col = 0.11,
      width = 0.9,
      height = 0.9,
      border = "single",
      title = " 󰸏 e1s - AWS ECS ",
      title_pos = "center",
    },
  }

  -- Auto-start e1s with profile/region selection on first open
  if not _G.e1s_started then
    vim.defer_fn(function()
      _G.e1s_started = true
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
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

-- ALT+2: Toggle e2s (EC2 browser) with profile/region selection
map({ "n", "t" }, "<A-2>", function()
  require("nvchad.term").toggle {
    pos = "float",
    id = "e2sTerm",
    float_opts = {
      row = 0.12, -- ALT+2: e2s (EC2 Browser)
      col = 0.12,
      width = 0.9,
      height = 0.9,
      border = "single",
      title = " 󰸏 e2s - EC2 Browser ",
      title_pos = "center",
    },
  }

  -- Auto-start e2s on first open
  if not _G.e2s_started then
    vim.defer_fn(function()
      _G.e2s_started = true
      local bufnr = vim.api.nvim_get_current_buf()
      if vim.bo[bufnr].buftype == "terminal" then
        local chan = vim.b[bufnr].terminal_job_id
        if chan then
          vim.api.nvim_chan_send(chan, "e2s\n")
        end
      end
    end, 200)
  end
end, { desc = "terminal toggle e2s EC2 browser" })

-- ALT+p closes and kills any floating terminal (ALT+i/k/j/h/o/b/d/e/c/1/2)
-- Note: When in terminal mode with apps like k9s running, press Ctrl+q first to exit terminal mode,
-- then press ALT+p. Or use this mapping which attempts to kill the process first.
map({ "n", "t" }, "<A-p>", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype == "terminal" then
    local nvim_pid = vim.fn.getpid()
    local term_id = "floatTerm_" .. nvim_pid

    -- Kill tmux session if this is a tmux terminal
    if _G.tmux_sessions and _G.tmux_sessions[term_id] then
      local session_name = "nvim_" .. nvim_pid
      vim.fn.system("tmux kill-session -t " .. session_name .. " 2>/dev/null")
      _G.tmux_sessions[term_id] = nil
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
    _G.browsh_started = false
    _G.lazydocker_started = false
    _G.w3m_started = false
    _G.carbonyl_started = false
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
