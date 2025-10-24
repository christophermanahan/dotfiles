vim.g.base46_cache = vim.fn.stdpath "data" .. "/nvchad/base46/"
vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
    config = function()
      require "options"
    end,
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
pcall(dofile, vim.g.base46_cache .. "defaults")
pcall(dofile, vim.g.base46_cache .. "statusline")

require "nvchad.autocmds"

-- Force transparency after theme loads
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local highlights = {
      "Normal",
      "NormalFloat",
      "SignColumn",
      "NvimTreeNormal",
      "NvimTreeNormalNC",
      "StatusLine",
      "StatusLineNC",
      "TbLineBufOn",
      "TbLineBufOff",
      "TblineFill",
      "TelescopeNormal",
      "TelescopeBorder",
      "TelescopePromptNormal",
      "TelescopePromptBorder",
      "TelescopePromptTitle",
      "TelescopeResultsNormal",
      "TelescopeResultsBorder",
      "TelescopeResultsTitle",
      "TelescopePreviewNormal",
      "TelescopePreviewBorder",
      "TelescopePreviewTitle",
    }
    for _, hl in ipairs(highlights) do
      vim.api.nvim_set_hl(0, hl, { bg = "NONE" })
    end

    -- Set Visual highlight for better visibility with transparency
    vim.api.nvim_set_hl(0, "Visual", {
      bg = "#89b4fa", -- Catppuccin blue (bright for visibility)
      fg = "#1e1e2e", -- Dark text for contrast
      bold = true,
    })

    -- Set line numbers for better visibility with transparency
    vim.api.nvim_set_hl(0, "LineNr", { fg = "#6c7086" }) -- Darker gray (Catppuccin overlay1)
    vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#74c7ec", bold = true }) -- Bright cyan (Catppuccin sapphire)
  end,
})

-- Apply transparency immediately
vim.schedule(function()
  local highlights = {
    "Normal",
    "NormalFloat",
    "SignColumn",
    "NvimTreeNormal",
    "NvimTreeNormalNC",
    "StatusLine",
    "StatusLineNC",
    "TbLineBufOn",
    "TbLineBufOff",
    "TblineFill",
    "TelescopeNormal",
    "TelescopeBorder",
    "TelescopePromptNormal",
    "TelescopePromptBorder",
    "TelescopePromptTitle",
    "TelescopeResultsNormal",
    "TelescopeResultsBorder",
    "TelescopeResultsTitle",
    "TelescopePreviewNormal",
    "TelescopePreviewBorder",
    "TelescopePreviewTitle",
  }
  for _, hl in ipairs(highlights) do
    vim.api.nvim_set_hl(0, hl, { bg = "NONE" })
  end

  -- Set Visual highlight for better visibility with transparency
  vim.api.nvim_set_hl(0, "Visual", {
    bg = "#89b4fa", -- Catppuccin blue (bright for visibility)
    fg = "#1e1e2e", -- Dark text for contrast
    bold = true,
  })

  -- Set line numbers for better visibility with transparency
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#6c7086" }) -- Darker gray (Catppuccin overlay1)
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#74c7ec", bold = true }) -- Bright cyan (Catppuccin sapphire)

  require "mappings"
end)

-- Force Telescope transparency when it opens
vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopePrompt",
  callback = function()
    vim.schedule(function()
      local telescope_highlights = {
        "TelescopeNormal",
        "TelescopeBorder",
        "TelescopePromptNormal",
        "TelescopePromptBorder",
        "TelescopePromptTitle",
        "TelescopePromptPrefix",
        "TelescopeResultsNormal",
        "TelescopeResultsBorder",
        "TelescopeResultsTitle",
        "TelescopePreviewNormal",
        "TelescopePreviewBorder",
        "TelescopePreviewTitle",
      }
      for _, hl in ipairs(telescope_highlights) do
        vim.api.nvim_set_hl(0, hl, { bg = "NONE" })
      end
    end)
  end,
})
