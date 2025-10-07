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
}
