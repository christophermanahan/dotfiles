-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua
local utils = require "utils"

local function gen_highlights(name, color)
  local M = {}
  M["St_" .. name .. "_bg"] = {
    fg = "black",
    bg = color,
  }

  M["St_" .. name .. "_txt"] = {
    fg = color,
    bg = "one_bg",
  }

  M["St_" .. name .. "_sep"] = {
    fg = color,
    bg = "black",
  }
  return M
end

local function gen_block(txt, icon, sep_l_hlgroup, iconHl_group, txt_hl_group)
  return sep_l_hlgroup
    .. ""
    .. iconHl_group
    .. icon
    .. " "
    .. txt_hl_group
    .. " "
    .. txt
    .. "%#St_sep_r#"
    .. ""
    .. " %#ST_EmptySpace#"
end

local function stbufnr()
  return vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
end

local function file_display()
  local icon = "󰈚"
  local path = vim.api.nvim_buf_get_name(stbufnr())
  local name = (path == "" and "empty ") or path:match "([^/\\]+)[/\\]*$"

  if name ~= "empty " then
    local devicons_present, devicons = pcall(require, "nvim-web-devicons")

    if devicons_present then
      local ft_icon = devicons.get_icon(name)
      icon = (ft_icon ~= nil and ft_icon) or icon
    end
  end

  return { name, icon }
end

---@class ChadrcConfig
local M = {}
local path_text = ""

M.ui = {
  hl_override = {
    NvimTreeGitNew = { fg = "yellow" },
    NvimTreeGitIgnored = { fg = "white" },
    NvimTreeGitDirty = { fg = "pink" },
    NvimTreeGitDeleted = { fg = "red" },
    Visual = { bg = "#383d42" },
  },
  hl_add = utils.merge_table(gen_highlights("path", "purple"), gen_highlights("file", "red")),
  transparency = true,
  theme = "catppuccin",
  statusline = {
    theme = "minimal",
    separator_style = "round",
    order = { "cwd", "path", "file", "git", "%=", "lsp", "diagnostics", "cursor", "mode" },
    modules = {
      path = function()
        if vim.fn.expand "%" == "NvimTree_1" or vim.fn.expand("%"):sub(1, 4) == "term" or vim.fn.expand "%" == "" then
          if vim.fn.expand "%" == "" then
            path_text = ""
            return " %#EmptySpace#"
          elseif #path_text == 0 then
            return " %#EmptySpace#"
          else
            return gen_block(path_text, "", "%#St_path_sep#", "%#St_path_bg#", "%#St_path_txt#")
          end
        else
          path_text = vim.fn.fnamemodify(vim.fn.expand "%:h", ":p:~:."):sub(1, -2)
          return gen_block(path_text, "", "%#St_path_sep#", "%#St_path_bg#", "%#St_path_txt#")
        end
      end,
      file = function()
        local file_display = file_display()
        if file_display[1] == "NvimTree_1" then
          return gen_block("filetree", file_display[2], "%#St_file_sep#", "%#St_file_bg#", "%#St_file_txt#")
        end
        return gen_block(file_display[1], file_display[2], "%#St_file_sep#", "%#St_file_bg#", "%#St_file_txt#")
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
