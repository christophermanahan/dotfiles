require "nvchad.options"

local o = vim.o
o.relativenumber = true

-- Enable macOS clipboard integration
-- This allows Neovim to access the system clipboard via the + register
vim.opt.clipboard = "unnamedplus"

-- Speed up ESC key in terminal mode (pass through to shell faster)
-- This makes vi-mode ESC responsive in floating terminals (tmux, Claude Code, etc.)
o.ttimeoutlen = 10  -- 10ms timeout for key codes (default is 50ms)

-- Make nvim-tree transparent
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NvimTreeVertSplit", { bg = "NONE" })
  end,
})
