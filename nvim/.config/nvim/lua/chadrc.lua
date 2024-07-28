-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua
--

local function gen_hl(name, col)
  local M = {}
  M["St_" .. name .. "_bg"] = {
    fg = "black",
    bg = col,
  }

  M["St_" .. name .. "_txt"] = {
    fg = col,
    bg = "one_bg",
  }

  M["St_" .. name .. "_sep"] = {
    fg = col,
    bg = "black",
  }
  return M
end

local function gen_block(txt, sep_l_hlgroup, iconHl_group, txt_hl_group)
  return sep_l_hlgroup
    .. ""
    .. iconHl_group
    .. ""
    .. " "
    .. txt_hl_group
    .. " "
    .. txt
    .. "%#St_sep_r#"
    .. ""
    .. " %#ST_EmptySpace#"
end

---@class ChadrcConfig
local M = {}

M.ui = {
  hl_override = {
    NvimTreeGitNew = { fg = "yellow" },
    NvimTreeGitIgnored = { fg = "white" },
    NvimTreeGitDirty = { fg = "pink" },
    NvimTreeGitDeleted = { fg = "red" },
    Visual = { bg = "#383d42" },
  },
  hl_add = gen_hl("path", "purple"),
  theme = "catppuccin",
  statusline = {
    theme = "minimal",
    separator_style = "round",
    order = { "cwd", "path", "file", "git", "%=", "lsp", "diagnostics", "cursor", "mode" },
    modules = {
      path = function()
        local text = vim.fn.fnamemodify(vim.fn.expand "%:h", ":p:~:."):sub(1, -2)
        if vim.fn.expand "%" == "NvimTree_1" or #text == 0 then
          return " %#ST_EmptySpace#"
        end
        return gen_block(text, "%#St_path_sep#", "%#St_path_bg#", "%#St_path_txt#")
      end,
    },
  },
  tabufline = {
    order = { "treeOffset", "buffers", "tabs" },
  },
}

M.base46 = {
  integrations = {
    "codeactionmenu",
    "dap",
    "neogit",
    "rainbowdelimiters",
    "notify",
    "trouble",
  },
}

M.lsp = { signature = false }

return M
