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

-- Terminal mode: double ESC to enter normal mode
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Enter terminal normal mode" })

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
    "<leader>X",
    ":BufOnly<CR>",
    desc = "close all other buffers",
    icon = "󰟢",
  },
  {
    "<leader>gh",
    ":Neogit<CR>",
    desc = "git",
    icon = {
      icon = "",
      color = "green",
    },
  },
  {
    mode = { "n", "v" }, -- NORMAL and VISUAL mode
    {
      "ga",
      function()
        require("tiny-code-action").code_action()
      end,
      desc = "code actions",
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
    ":vertical resize -10<CR>",
    desc = "decrease width",
    icon = {
      icon = "󰼁",
      color = "blue",
    },
  },
  {
    "<leader>>",
    ":vertical resize +10<CR>",
    desc = "increase width",
    icon = {
      icon = "󰼀",
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
      row = 0.05,
      col = 0.03,
      width = 0.85,
      height = 0.85,
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
      row = 0.05,
      col = 0.08,
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

-- ALT+j toggles the k9s terminal and starts k9s on first open
map({ "n", "t" }, "<A-j>", function()
  local term = require "nvchad.term"

  term.toggle {
    pos = "float",
    id = "k9s_term",
    float_opts = {
      row = 0.05,
      col = 0.13,
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
          vim.api.nvim_chan_send(job_id, "k9s\n")
          _G.k9s_started = true
        else
          vim.notify("Failed to get terminal job_id: " .. tostring(job_id), vim.log.levels.WARN)
        end
      else
        vim.notify("Current buffer is not a terminal: " .. vim.bo[bufnr].buftype, vim.log.levels.WARN)
      end
    end, 200)
  end
end, { desc = "terminal toggle k9s" })

-- ALT+o closes and kills any floating terminal (ALT+i/k/j)
map({ "n", "t" }, "<A-o>", function()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype == "terminal" then
    -- Reset all terminal session tracking so they restart on next toggle
    local nvim_pid = vim.fn.getpid()
    local term_id = "floatTerm_" .. nvim_pid

    -- Reset tmux session tracking
    if _G.tmux_sessions then
      _G.tmux_sessions[term_id] = nil
    end

    -- Reset Claude and k9s tracking
    _G.claude_started = false
    _G.k9s_started = false

    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end, { desc = "kill any floating terminal" })
