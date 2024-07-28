require "nvchad.mappings"
local wk = require "which-key"

wk.add {
  {
    "<leader>ra",
    function()
      require "nvchad.lsp.renamer"()
    end,
    desc = "Go to type definition",
    icon = "󰊄",
  },
  {
    "<leader>D",
    vim.lsp.buf.type_definition,
    desc = "Go to type definition",
    icon = "󰅩",
  },
  {
    "gD",
    vim.lsp.buf.declaration,
    desc = "Go to declaration",
    icon = "󰅩",
  },
  {
    "gd",
    vim.lsp.buf.definition,
    desc = "Go to definition",
    icon = "󰅩",
  },
  {
    "gi",
    vim.lsp.buf.implementation,
    desc = "Go to implementation",
    icon = "󰆧",
  },
  {
    "<leader>S",
    ":GrugFar<CR>",
    desc = "Search and Replace",
    icon = "",
  },
  {
    "gC",
    ":tabnew<CR>",
    desc = "New Tab",
    icon = "",
  },
  {
    "gt",
    ":tabnext<CR>",
    desc = "Next Tab",
    icon = "",
  },
  {
    "gT",
    ":tabprevious<CR>",
    desc = "Previous Tab",
    icon = "",
  },
  {
    "<leader>X",
    ":BufOnly<CR>",
    desc = "Close all other buffers",
    icon = "󰟢",
  },
  {
    "<leader>gh",
    ":Neogit<CR>",
    desc = "Neogit",
    icon = "",
  },
  {
    mode = { "n", "v" }, -- NORMAL and VISUAL mode
    {
      "ga",
      function()
        require("actions-preview").code_actions()
      end,
      desc = "Code Actions",
      icon = "",
    },
  },
  {
    "gpd",
    function()
      require("goto-preview").goto_preview_definition()
    end,
    desc = "Preview Definition",
    icon = "󰅩",
  },
  {
    "gpt",
    function()
      require("goto-preview").goto_preview_type_definition()
    end,
    desc = "Preview Type Definition",
    icon = "󰊄",
  },
  {
    "gpi",
    function()
      require("goto-preview").goto_preview_implementation()
    end,
    desc = "Preview Implementation",
    icon = "󰆧",
  },
  {
    "gpD",
    function()
      require("goto-preview").goto_preview_declaration()
    end,
    desc = "Preview Declaration",
    icon = "󰀫",
  },
  {
    "gr",
    function()
      require("goto-preview").goto_preview_references()
    end,
    desc = "View References",
    icon = "󰈇",
  },
  {
    "gP",
    function()
      require("goto-preview").close_all_win()
    end,
    desc = "Close Preview",
    icon = "󰟢",
  },
  {
    mode = { "n", "v" }, -- NORMAL and VISUAL mode
    { "<leader>Q", "<cmd>qa<cr>", desc = "Quit All", icon = "󰟢" },
    { "<leader>q", "<cmd>q<cr>", desc = "Quit", icon = "󰟢" },
    { "<leader>w", "<cmd>w<cr>", desc = "Write", icon = "" },
  },
}
