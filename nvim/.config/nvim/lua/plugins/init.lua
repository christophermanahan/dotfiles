return {
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").load_extension "fzf"
    end,
  },

  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        css = { "prettierd" },
        html = { "prettierd" },
      },

      format_on_save = {
        timeout_ms = 500,
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
    opts = {
      sources = {
        { name = "copilot" },
        { name = "nvim_lsp_signature_help" },
      },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      actions = {
        change_dir = {
          global = true,
        },
      },
      view = {
        adaptive_size = true,
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
        "tsserver",
        "vtsls",
        "marksman",
        "docker_compose_language_service",
        "dockerls",
        "prismals",
        "rust_analyzer",
        "terraformls",
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
    "aznhe21/actions-preview.nvim",
    event = "BufEnter",
    opts = {
      telescope = {
        sorting_strategy = "ascending",
        layout_strategy = "vertical",
        layout_config = {
          width = 0.3,
          height = 0.3,
          prompt_position = "top",
          preview_height = function(a)
            print(vim.inspect(a))
            return 10
          end,
        },
      },
    },
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
}
