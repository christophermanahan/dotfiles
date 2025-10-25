return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false,
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "MeanderingProgrammer/render-markdown.nvim",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        },
      },
    },
  },
  opts = {
    ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | "ollama"
    provider = "copilot", -- Using GitHub Copilot
    auto_suggestions_provider = "copilot",

    -- Copilot will use your existing copilot.lua authentication
    -- No additional configuration needed - avante will leverage
    -- the copilot plugin already installed in your setup

    -- Behavior settings
    behaviour = {
      auto_suggestions = false, -- Don't auto-suggest on every change
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false, -- Manual control over applying changes
      support_paste_from_clipboard = true,
    },

    -- Transparency and theme integration
    highlights = {
      diff = {
        current = "DiffText",
        incoming = "DiffAdd",
      },
    },

    -- Window configuration
    windows = {
      position = "right", -- Open on right side like many IDE assistants
      wrap = true,
      width = 40, -- Percentage of screen width
      sidebar_header = {
        align = "center",
        rounded = true,
      },
    },

    -- Mappings (using your existing keybinding patterns)
    mappings = {
      --- @class AvanteConflictMappings
      diff = {
        ours = "co",
        theirs = "ct",
        all_theirs = "ca",
        both = "cb",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<M-l>", -- ALT+l to accept suggestion
        next = "<M-]>",   -- ALT+] for next
        prev = "<M-[>",   -- ALT+[ for previous
        dismiss = "<C-]>",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<CR>",
        insert = "<C-s>",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<Tab>",
        reverse_switch_windows = "<S-Tab>",
      },
    },

    -- File selector using Telescope (already in your config)
    file_selector = {
      provider = "telescope",
    },

    -- Hints configuration
    hints = {
      enabled = true,
    },

    -- System prompt customization
    system_prompt = [[
You are an expert software engineer with deep knowledge of modern development practices.
When suggesting code changes:
- Follow existing code style and patterns in the file
- Provide clear explanations for your suggestions
- Consider performance and maintainability
- Use TypeScript best practices when applicable
- Keep suggestions concise and actionable
]],
  },
}
