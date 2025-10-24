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
map("t", "<C-q>", "<C-\\><C-n>", { desc = "Enter terminal normal mode" })

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
          "--max-depth", "3",
          "--exclude", ".git",
          "--exclude", "node_modules",
          "--exclude", ".cache",
          "--exclude", ".npm",
          "--exclude", ".cargo",
          "--exclude", ".local",
          "--exclude", "Library",
          "--exclude", "Applications",
          "--exclude", ".Trash",
          "--exclude", "target",
          "--exclude", "dist",
          "--exclude", "build",
          "--exclude", ".next",
          "--exclude", ".venv",
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
      function()
        -- Unified code actions menu: LSP (prioritized) + AI
        -- Requirements:
        -- 1. LSP actions appear first with previews
        -- 2. Copilot AI actions appear below
        -- 3. Both types show meaningful previews
        -- 4. All actions actually execute correctly

        local telescope_actions = require "telescope.actions"
        local action_state = require "telescope.actions.state"
        local pickers = require "telescope.pickers"
        local finders = require "telescope.finders"
        local previewers = require "telescope.previewers"
        local conf = require("telescope.config").values

        -- Collect all actions
        local function collect_actions()
          local all_actions = {}

          -- Get LSP code actions
          local params = vim.lsp.util.make_range_params()
          params.context = {
            diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line "." - 1 }),
          }

          local lsp_results = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)

          -- Add LSP actions (prioritized first)
          if lsp_results then
            for client_id, resp in pairs(lsp_results) do
              if resp.result then
                for _, action in ipairs(resp.result) do
                  table.insert(all_actions, {
                    type = "lsp",
                    display = "[LSP] " .. action.title,
                    title = action.title,
                    kind = action.kind or "action",
                    preview = string.format("Type: %s\n\nAction: %s", action.kind or "Code Action", action.title),
                    lsp_action = action,
                  })
                end
              end
            end
          end

          -- Add separator if we have LSP actions
          if #all_actions > 0 then
            table.insert(all_actions, {
              type = "separator",
              display = "────────── AI Actions ──────────",
              preview = "",
            })
          end

          -- Add Copilot AI actions
          local ai_actions = {
            {
              type = "copilot",
              display = "[AI] Explain Code",
              title = "Explain",
              preview = "Ask Copilot to explain the selected code in detail",
              command = "Explain",
            },
            {
              type = "copilot",
              display = "[AI] Review Code",
              title = "Review",
              preview = "Ask Copilot to review the selected code for issues and improvements",
              command = "Review",
            },
            {
              type = "copilot",
              display = "[AI] Fix Code",
              title = "Fix",
              preview = "Ask Copilot to fix problems in the selected code",
              command = "Fix",
            },
            {
              type = "copilot",
              display = "[AI] Optimize Code",
              title = "Optimize",
              preview = "Ask Copilot to optimize the selected code for performance and readability",
              command = "Optimize",
            },
            {
              type = "copilot",
              display = "[AI] Add Documentation",
              title = "Docs",
              preview = "Ask Copilot to add documentation comments for the selection",
              command = "Docs",
            },
            {
              type = "copilot",
              display = "[AI] Generate Tests",
              title = "Tests",
              preview = "Ask Copilot to generate tests for the selected code",
              command = "Tests",
            },
          }

          for _, ai_action in ipairs(ai_actions) do
            table.insert(all_actions, ai_action)
          end

          return all_actions
        end

        local all_actions = collect_actions()

        -- Show unified picker with preview
        pickers
          .new({}, {
            prompt_title = "Code Actions (LSP + AI)",
            finder = finders.new_table {
              results = all_actions,
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = entry.display,
                  ordinal = entry.display,
                }
              end,
            },
            sorter = conf.generic_sorter {},
            previewer = previewers.new_buffer_previewer {
              define_preview = function(self, entry)
                local lines = vim.split(entry.value.preview or "No preview available", "\n")
                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
              end,
            },
            attach_mappings = function(prompt_bufnr)
              telescope_actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                if not selection then
                  return
                end

                telescope_actions.close(prompt_bufnr)

                local entry = selection.value

                -- Handle separator (do nothing)
                if entry.type == "separator" then
                  return
                end

                -- Execute LSP action
                if entry.type == "lsp" then
                  local action = entry.lsp_action
                  if action.edit then
                    vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                  end
                  if action.command then
                    local command = action.command
                    local fn = vim.lsp.commands[command.command] or vim.lsp.buf.execute_command
                    fn(command)
                  end
                end

                -- Execute Copilot action
                if entry.type == "copilot" then
                  vim.cmd("CopilotChat" .. entry.command)
                end
              end)
              return true
            end,
          })
          :find()
      end,
      desc = "code actions (LSP + AI)",
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
  {
    "<leader>rc",
    function()
      require("base46").compile()
      vim.notify("Cache regenerated!", vim.log.levels.INFO)
    end,
    desc = "regenerate nvchad cache",
    icon = {
      icon = "󰑓",
      color = "orange",
    },
  },
  {
    "<leader>lp",
    ":Lazy profile<CR>",
    desc = "lazy plugin profile",
    icon = {
      icon = "󰔚",
      color = "purple",
    },
  },
  {
    "<leader>cp",
    function()
      require("copilot.panel").open()
    end,
    desc = "open copilot panel",
    icon = {
      icon = "",
      color = "cyan",
    },
  },
  {
    "<leader>cs",
    ":Copilot status<CR>",
    desc = "copilot status",
    icon = {
      icon = "",
      color = "cyan",
    },
  },
  {
    "<leader>ca",
    ":Copilot auth<CR>",
    desc = "copilot authenticate",
    icon = {
      icon = "",
      color = "cyan",
    },
  },
  {
    "<leader>cc",
    function()
      require("CopilotChat").toggle()
    end,
    desc = "toggle copilot chat",
    icon = {
      icon = "",
      color = "cyan",
    },
  },
  {
    mode = { "n", "v" },
    {
      "<leader>ce",
      function()
        local actions = require "CopilotChat.actions"
        require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
      end,
      desc = "copilot actions (telescope)",
      icon = {
        icon = "",
        color = "cyan",
      },
    },
  },
  {
    mode = "v",
    {
      "<leader>cf",
      ":CopilotChatFix<CR>",
      desc = "copilot fix",
      icon = {
        icon = "",
        color = "red",
      },
    },
    {
      "<leader>co",
      ":CopilotChatOptimize<CR>",
      desc = "copilot optimize",
      icon = {
        icon = "",
        color = "yellow",
      },
    },
    {
      "<leader>cd",
      ":CopilotChatDocs<CR>",
      desc = "copilot add docs",
      icon = {
        icon = "",
        color = "green",
      },
    },
    {
      "<leader>ct",
      ":CopilotChatTests<CR>",
      desc = "copilot generate tests",
      icon = {
        icon = "",
        color = "purple",
      },
    },
  },
}

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
      row = 0.04, -- ALT+i: Tmux terminal
      col = 0.04,
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
      row = 0.06, -- ALT+j: k9s
      col = 0.06,
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
      row = 0.08, -- ALT+h: Lazygit
      col = 0.08,
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
      row = 0.10, -- ALT+o: OpenAI CLI
      col = 0.10,
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
      row = 0.12, -- ALT+b: Browsh browser (larger window)
      col = 0.12,
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
      row = 0.03, -- ALT+d: Lazydocker (large window)
      col = 0.03,
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
      row = 0.05,
      col = 0.05,
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
          row = 0.05,
          col = 0.05,
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
      row = 0.09, -- ALT+c: Carbonyl browser
      col = 0.09,
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

-- ALT+p closes and kills any floating terminal (ALT+i/k/j/h/o/b/d/e/c)
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
