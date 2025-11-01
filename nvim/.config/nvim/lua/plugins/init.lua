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
    lazy = false, -- Load on startup
    event = "VimEnter", -- Start when Neovim starts
    opts = {
      suggestion = { enabled = false },
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<CR>",
          refresh = "gr",
          open = "<M-CR>", -- Alt+Enter to open panel
        },
        layout = {
          position = "right", -- or "bottom", "top", "left"
          ratio = 0.4,
        },
      },
    },
  },

  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "copilot.lua" },
    opts = {},
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      prompts = {
        Explain = {
          prompt = "/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.",
        },
        Review = {
          prompt = "/COPILOT_REVIEW Review the selected code.",
        },
        Fix = {
          prompt = "/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.",
        },
        Optimize = {
          prompt = "/COPILOT_GENERATE Optimize the selected code to improve performance and readability.",
        },
        Docs = {
          prompt = "/COPILOT_GENERATE Please add documentation comment for the selection.",
        },
        Tests = {
          prompt = "/COPILOT_GENERATE Please generate tests for my code.",
        },
        FixDiagnostic = {
          prompt = "Please assist with the following diagnostic issue in file:",
        },
      },
    },
    config = function(_, opts)
      local chat = require "CopilotChat"
      local select = require "CopilotChat.select"

      -- Use unnamed register for selections
      opts.selection = select.unnamed

      chat.setup(opts)
    end,
  },

  { "hrsh7th/cmp-nvim-lsp-signature-help" },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "zbirenbaum/copilot-cmp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
    opts = function(_, opts)
      local cmp = require "cmp"

      -- Get default NvChad mappings first
      local default_mappings = require("nvchad.configs.cmp").mapping or {}

      -- Extend with custom mappings
      opts.mapping = cmp.mapping.preset.insert(vim.tbl_deep_extend("force", default_mappings, {
        -- Vi-style navigation through completion menu
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-k>"] = cmp.mapping.select_prev_item(),

        -- Scroll documentation window (only works if doc window is visible)
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),

        -- Close completion menu
        ["<C-e>"] = cmp.mapping.abort(),

        -- Manually trigger completion - multiple options
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-x><C-o>"] = cmp.mapping.complete(), -- Standard vim omnifunc trigger
      }))

      -- Enable documentation window
      opts.window = {
        documentation = cmp.config.window.bordered(),
      }

      -- Add custom sources
      opts.sources = vim.list_extend(opts.sources or {}, {
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "copilot" },
        { name = "path" },
        { name = "buffer" },
        { name = "luasnip" },
        { name = "nvim_lua" },
      })

      -- Custom sorting
      opts.sorting = {
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
      }

      return opts
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

        -- Enable flash.nvim in nvimtree
        vim.keymap.set("n", "s", function()
          require("flash").jump()
        end, opts "Flash jump")
        vim.keymap.set("n", "S", function()
          require("flash").treesitter()
        end, opts "Flash treesitter")
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
    event = "User FilePost",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "html",
        "cssls",
        -- vtsls removed - using typescript-tools.nvim instead
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
          -- Skip tsserver, vtsls (using typescript-tools.nvim), and lua_ls
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
    "numToStr/BufOnly.nvim",
    event = "BufEnter",
  },

  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    opts = {
      width = 100,
      height = 20,
      focus_on_open = true,
      dismiss_on_move = false,
      force_close = true,
      bufhidden = "wipe",
      preview_window_title = { enable = true, position = "left" },
      zindex = 1,
      -- Just open first result when there are multiple, don't show picker
      references = {
        telescope = false, -- Disable telescope picker
      },
      -- Prevent opening multiple windows
      stack_floating_preview_windows = false,
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
        mode = { "n", "o" },  -- Removed "x" (visual mode) to allow nvim-surround to use S in visual
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "o" },  -- Removed "x" (visual mode) to allow nvim-surround to use S in visual
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
    opts = {
      input = {
        -- Center the input box
        relative = "editor",
        prefer_width = 60,
        max_width = { 140, 0.9 },
        min_width = { 40, 0.3 },
        win_options = {
          winblend = 0,
        },
        override = function(conf)
          conf.col = math.floor((vim.o.columns - conf.width) / 2)
          conf.row = math.floor(vim.o.lines / 2) - 2
          return conf
        end,
      },
    },
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

  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      -- Auto-close preview when switching buffers
      vim.g.mkdp_auto_close = 1
      -- Use default browser
      vim.g.mkdp_browser = ""
      -- Preview page title (uses filename)
      vim.g.mkdp_page_title = "${name}"
    end,
  },
}
