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
    bg = "NONE",
  }

  M["St_" .. name .. "_sep"] = {
    fg = color,
    bg = "NONE",
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

-- Cache git branch to avoid flickering from repeated shell calls
local git_branch_cache = ""
local function update_git_branch()
  vim.schedule(function()
    local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
    git_branch_cache = branch
  end)
end

-- Update git branch on relevant events
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged" }, {
  callback = update_git_branch,
})

-- Initialize git branch on startup
update_git_branch()

-- Cache LSP clients to avoid repeated queries on statusline refresh
local lsp_clients_cache = {}
local function update_lsp_clients(bufnr)
  if not bufnr then
    bufnr = vim.api.nvim_get_current_buf()
  end

  local lsp_names = {}
  if rawget(vim, "lsp") then
    for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
      -- Filter out Copilot from LSP status
      if client.name ~= "copilot" then
        table.insert(lsp_names, client.name)
      end
    end
  end

  lsp_clients_cache[bufnr] = lsp_names
end

-- Update LSP cache on attach/detach
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    update_lsp_clients(args.buf)
  end,
})

vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    update_lsp_clients(args.buf)
  end,
})

-- Initialize LSP cache for current buffer
update_lsp_clients()

M.ui = {
  hl_override = {
    Normal = { bg = "NONE" },
    NormalFloat = { bg = "NONE" },
    SignColumn = { bg = "NONE" },
    NvimTreeNormal = { bg = "NONE" },
    NvimTreeNormalNC = { bg = "NONE" },
    NvimTreeGitNew = { fg = "yellow" },
    NvimTreeGitIgnored = { fg = "white" },
    NvimTreeGitDirty = { fg = "pink" },
    NvimTreeGitDeleted = { fg = "red" },
    St_gitIcons = { fg = "green" },
    St_Lsp = { fg = "pink" },
    -- Line numbers (brighter for transparency visibility)
    LineNr = { fg = "#6c7086" }, -- Darker gray (Catppuccin overlay1)
    CursorLineNr = { fg = "#74c7ec", bold = true }, -- Bright cyan (Catppuccin sapphire)
    -- Telescope transparency
    TelescopeNormal = { bg = "NONE" },
    TelescopeBorder = { bg = "NONE" },
    TelescopePromptNormal = { bg = "NONE" },
    TelescopePromptBorder = { bg = "NONE" },
    TelescopePromptTitle = { bg = "NONE" },
    TelescopeResultsNormal = { bg = "NONE" },
    TelescopeResultsBorder = { bg = "NONE" },
    TelescopeResultsTitle = { bg = "NONE" },
    TelescopePreviewNormal = { bg = "NONE" },
    TelescopePreviewBorder = { bg = "NONE" },
    TelescopePreviewTitle = { bg = "NONE" },
    -- Visual mode highlight (bright for transparency visibility)
    Visual = { bg = "#89b4fa", fg = "#1e1e2e", bold = true },
    StatusLine = { bg = "NONE" },
    StatusLineNC = { bg = "NONE" },
    TbLineBufOn = { bg = "NONE" },
    TbLineBufOff = { bg = "NONE" },
    TblineFill = { bg = "NONE" },
    TbLineTabNewBtn = { bg = "NONE" },
    TbLineTabOn = { bg = "NONE" },
    TbLineTabOff = { bg = "NONE" },
    TbLineTabCloseBtn = { bg = "NONE" },
    TbLineThemeToggleBtn = { bg = "NONE" },
    TbLineCloseAllBufsBtn = { bg = "NONE" },
  },
  hl_add = utils.merge_table(
    utils.merge_table(gen_highlights("path", "purple"), gen_highlights("file", "red")),
    gen_highlights("gitbranch", "cyan")
  ),
  transparency = true,
  statusline = {
    theme = "minimal",
    separator_style = "round",
    order = { "gitbranch", "cwd", "path", "file", "%=", "lsp", "diagnostics", "cursor", "mode" },
    modules = {
      gitbranch = function()
        if git_branch_cache ~= "" then
          return gen_block(git_branch_cache, "", "%#St_gitbranch_sep#", "%#St_gitbranch_bg#", "%#St_gitbranch_txt#")
        end
        return ""
      end,
      path = function()
        -- Cache expand call to avoid multiple function calls per statusline refresh
        local current_file = vim.fn.expand "%"
        if current_file == "NvimTree_1" or current_file:sub(1, 4) == "term" or current_file == "" then
          if current_file == "" then
            path_text = ""
            return " %#EmptySpace#"
          elseif #path_text == 0 then
            return " %#EmptySpace#"
          else
            return gen_block(path_text, "", "%#St_path_sep#", "%#St_path_bg#", "%#St_path_txt#")
          end
        else
          path_text = vim.fn.fnamemodify(current_file .. ":h", ":p:~:."):sub(1, -2)
          if #path_text == 0 then
            return " %#EmptySpace#"
          end
          return gen_block(path_text, "", "%#St_path_sep#", "%#St_path_bg#", "%#St_path_txt#")
        end
      end,
      file = function()
        local file_info = file_display()
        if file_info[1] == "NvimTree_1" then
          return gen_block("filetree", "󰉋", "%#St_file_sep#", "%#St_file_bg#", "%#St_file_txt#")
        end
        return gen_block(file_info[1], file_info[2], "%#St_file_sep#", "%#St_file_bg#", "%#St_file_txt#")
      end,
      lsp = function()
        -- Use cached LSP clients to avoid repeated queries
        local bufnr = stbufnr()
        local lsp_names = lsp_clients_cache[bufnr] or {}

        if #lsp_names == 0 then
          return ""
        end

        return (vim.o.columns > 100 and ("%#St_Lsp#" .. "  " .. table.concat(lsp_names, ", "))) or "  LSP "
      end,
    },
  },
  tabufline = {
    order = { "treeOffset", "buffers", "tabs" },
  },
}

M.base46 = {
  theme = "embark",
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

M.term = {
  winopts = { number = false, relativenumber = false },
  sizes = { sp = 0.3, vsp = 0.2, ["bo sp"] = 0.3, ["bo vsp"] = 0.2 },
  float = {
    relative = "editor",
    row = 0.1,
    col = 0.1,
    width = 0.8,
    height = 0.7,
    border = "single",
    title = " 󰆍 Terminal ",
    title_pos = "center",
  },
}

return M
