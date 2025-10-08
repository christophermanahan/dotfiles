require "nvchad.options"

local o = vim.o
o.relativenumber = true

-- Make nvim-tree transparent
vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "NvimTreeVertSplit", { bg = "NONE" })
    -- Make cursor line 80% transparent
    vim.api.nvim_set_hl(0, "NvimTreeCursorLine", { bg = "NONE", blend = 80 })
  end,
})
