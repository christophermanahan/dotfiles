return {
  { "gitsigns", enabled = false },
  { "FelipeLema/cmp-async-path", enabled = false },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").load_extension "fzf"
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha", -- Change to "latte" for light theme with dark text
      transparent_background = true,
      dim_inactive = {
        enabled = false,
      },
      color_overrides = {
        mocha = {
          -- Override with brightest possible colors
          text = "#ffffff", -- Pure white for maximum brightness
          subtext1 = "#f5f5f5",
          subtext0 = "#eeeeee",
        },
      },
      custom_highlights = function(colors)
        return {
          -- Normal text - brightest white
          Normal = { fg = "#ffffff" },
          NormalNC = { fg = "#ffffff" },

          -- Syntax highlighting with maximum brightness
          Comment = { fg = "#b4befe", style = { "italic" } }, -- Bright blue
          Constant = { fg = "#fab387" }, -- Bright orange
          String = { fg = "#a6e3a1" }, -- Bright green
          Character = { fg = "#a6e3a1" },
          Number = { fg = "#fab387" },
          Boolean = { fg = "#fab387" },
          Float = { fg = "#fab387" },

          Identifier = { fg = "#ffffff" }, -- Pure white
          Function = { fg = "#89dceb" }, -- Bright cyan

          Statement = { fg = "#cba6f7" }, -- Bright mauve
          Conditional = { fg = "#f38ba8" }, -- Bright red
          Repeat = { fg = "#f38ba8" },
          Label = { fg = "#fab387" },
          Operator = { fg = "#89dceb" },
          Keyword = { fg = "#f38ba8" },
          Exception = { fg = "#f38ba8" },

          PreProc = { fg = "#f9e2af" }, -- Bright yellow
          Include = { fg = "#f38ba8" },
          Define = { fg = "#f38ba8" },
          Macro = { fg = "#f38ba8" },
          PreCondit = { fg = "#89dceb" },

          Type = { fg = "#f9e2af" },
          StorageClass = { fg = "#f9e2af" },
          Structure = { fg = "#89dceb" },
          Typedef = { fg = "#f9e2af" },

          Special = { fg = "#94e2d5" }, -- Bright teal
          SpecialChar = { fg = "#94e2d5" },
          Tag = { fg = "#f38ba8" },
          Delimiter = { fg = "#ffffff" },
          SpecialComment = { fg = "#89dceb" },
          Debug = { fg = "#fab387" },

          -- UI elements
          Title = { fg = "#89dceb", style = { "bold" } },
          Directory = { fg = "#89dceb" },

          -- Variables with bright colors
          ["@variable"] = { fg = "#ffffff" },
          ["@variable.builtin"] = { fg = "#f38ba8" },
          ["@variable.parameter"] = { fg = "#fab387" },
          ["@variable.member"] = { fg = "#89dceb" },

          -- Functions
          ["@function"] = { fg = "#89dceb" },
          ["@function.builtin"] = { fg = "#94e2d5" },
          ["@function.method"] = { fg = "#89dceb" },

          -- Keywords
          ["@keyword"] = { fg = "#f38ba8" },
          ["@keyword.function"] = { fg = "#cba6f7" },
          ["@keyword.operator"] = { fg = "#89dceb" },
          ["@keyword.return"] = { fg = "#f38ba8" },

          -- Types
          ["@type"] = { fg = "#f9e2af" },
          ["@type.builtin"] = { fg = "#f9e2af" },

          -- Strings and constants
          ["@string"] = { fg = "#a6e3a1" },
          ["@number"] = { fg = "#fab387" },
          ["@boolean"] = { fg = "#fab387" },
          ["@constant"] = { fg = "#fab387" },
          ["@constant.builtin"] = { fg = "#fab387" },

          -- Punctuation
          ["@punctuation.delimiter"] = { fg = "#ffffff" },
          ["@punctuation.bracket"] = { fg = "#ffffff" },
          ["@punctuation.special"] = { fg = "#94e2d5" },

          -- Properties and attributes
          ["@property"] = { fg = "#89dceb" },
          ["@attribute"] = { fg = "#f9e2af" },

          -- Tags (HTML/JSX)
          ["@tag"] = { fg = "#f38ba8" },
          ["@tag.attribute"] = { fg = "#f9e2af" },
          ["@tag.delimiter"] = { fg = "#ffffff" },
        }
      end,
    },
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "biome", "prettierd" },
        typescript = { "biome", "prettierd" },
        javascriptreact = { "biome", "prettierd" },
        typescriptreact = { "biome", "prettierd" },
        css = { "prettierd" },
        html = { "prettierd" },
        json = { "biome", "prettierd" },
        jsonc = { "biome", "prettierd" },
      },

      format_on_save = {
        timeout_ms = 2000,
        lsp_fallback = true,
      },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
    },
  },

  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "copilot.lua" },
    opts = {},
  },

  { "hrsh7th/cmp-nvim-lsp-signature-help" },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "zbirenbaum/copilot-cmp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    opts = function()
      local cmp = require "cmp"
      return {
        sources = {
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "copilot" },
          { name = "path" },
          { name = "buffer" },
          { name = "luasnip" },
          { name = "nvim_lua" },
        },
        sorting = {
          priority_weight = 2,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
        },
      }
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      on_attach = function(bufnr)
        local api = require "nvim-tree.api"
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Load default mappings first
        api.config.mappings.default_on_attach(bufnr)

        -- Explicitly ensure h and l work for navigation
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts "Close Directory")
        vim.keymap.set("n", "l", api.node.open.edit, opts "Open")

        -- Preserve smart-splits navigation with CTRL+hjkl
        vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, opts "Move to left pane")
        vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, opts "Move to bottom pane")
        vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, opts "Move to top pane")
        vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, opts "Move to right pane")
      end,
      actions = {
        change_dir = {
          global = true,
        },
      },
      view = {
        adaptive_size = true,
        width = {
          max = 60,
        },
      },
      live_filter = {
        prefix = "filter: ",
        always_show_folders = false,
      },
      renderer = {
        highlight_git = "none",
        icons = {
          web_devicons = {
            file = {
              enable = true,
              color = true,
            },
            folder = {
              enable = true,
              color = true,
            },
          },
          glyphs = {
            git = {
              untracked = "",
            },
          },
        },
      },
      update_focused_file = {
        enable = false,
      },
    },
  },

  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    opts = {},
  },

  {
    "kylechui/nvim-surround",
    event = "BufEnter",
    version = "*",
    opts = {},
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
  },

  {
    "pmizio/typescript-tools.nvim",
    event = "BufEnter",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {
      root_dir = require("lspconfig").util.root_pattern ".npmrc",
      settings = {
        expose_as_code_action = "all",
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    event = "BufEnter",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "html",
        "cssls",
        "vtsls",
        "marksman",
        "docker_compose_language_service",
        "dockerls",
        "prismals",
        "rust_analyzer",
        "terraformls",
        "pyright",
      },
      automatic_installation = true,
      handlers = {
        function(server)
          if server == "tsserver" or server == "vtsls" or server == "lua_ls" then
            return
          end
          require("lspconfig")[server].setup {
            capabilities = vim.tbl_deep_extend(
              "force",
              require("cmp_nvim_lsp").default_capabilities(),
              require("lsp-file-operations").default_capabilities()
            ),
          }
        end,
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "typescript",
        "javascript",
        "json",
      },
    },
  },

  { "sindrets/diffview.nvim" },

  {
    "NeogitOrg/neogit",
    event = "BufEnter",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {},
  },

  {
    "numToStr/BufOnly.nvim",
    event = "BufEnter",
  },

  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    opts = {
      width = 100,
      height = 20,
      references = {
        telescope = require("telescope.themes").get_dropdown { hide_preview = false },
      },
      focus_on_open = true,
      dismiss_on_move = false,
      force_close = true,
      bufhidden = "wipe",
      preview_window_title = { enable = true, position = "left" },
      zindex = 1,
    },
  },

  {
    "MeanderingProgrammer/markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "BufEnter",
  },

  {
    "rcarriga/nvim-notify",
    lazy = false,
    opts = {
      fps = 120,
      render = "compact",
      stages = "static",
      timeout = 3000,
    },
  },

  {
    "folke/trouble.nvim",
    event = "BufEnter",
    opts = {},
  },

  {
    "MagicDuck/grug-far.nvim",
    event = "BufEnter",
    opts = {},
  },

  {
    "folke/noice.nvim",
    lazy = false,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {},
  },

  {
    "christoomey/vim-tmux-navigator",
    event = "BufEnter",
    keys = {
      { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<CR>" },
      { "<C-j>", "<cmd><C-U>TmuxNavigateDown<CR>" },
      { "<C-k>", "<cmd><C-U>TmuxNavigateUp<CR>" },
      { "<C-l>", "<cmd><C-U>TmuxNavigateRight<CR>" },
      { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufEnter",
    opts = {},
  },

  {
    "RRethy/vim-illuminate",
    event = "BufEnter",
  },

  {
    "sontungexpt/better-diagnostic-virtual-text",
    event = "BufEnter",
    config = function()
      require("better-diagnostic-virtual-text").setup()
      vim.diagnostic.config {
        virtual_text = false,
      }
    end,
  },

  {
    "rachartier/tiny-code-action.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    event = "LspAttach",
    opts = {},
  },

  {
    "folke/flash.nvim",
    event = "BufEnter",
    opts = {
      modes = {
        char = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
    },
  },

  {
    "stevearc/dressing.nvim",
    event = "BufEnter",
    opts = {},
  },

  {
    "mrjones2014/smart-splits.nvim",
    event = "BufEnter",
    lazy = false,
    opts = {},
  },

  {
    "MTDL9/vim-log-highlighting",
    ft = "log",
  },
}
