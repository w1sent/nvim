return {
  {
    "sainnhe/everforest",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.everforest_background = "hard"
      vim.g.everforest_better_performance = 1
    end,
  },
  {
    "junegunn/fzf",
    run = function()
      vim.fn["fzf#install"]()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",
      },
    },
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup {
        defaults = {
          layout_strategy = "vertical",
          layout_config = {
            vertical = { width = 0.8, height = 0.8, preview_height = 0.5 },
          },
        },
      }
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    opts = {},
    -- stylua: ignore
  },
  {
    'echasnovski/mini.move',
    version = '*'
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" },
        },
        neorg = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "norg" },
        },
        typst = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "typst" },
        },
        tex = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "tex", "latex" },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = false,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
    },
    keys = {
      {
        "<leader>it",
        function()
          local image = require("image")
          -- Initialize if not set
          if vim.g.image_rendering_enabled == nil then
            vim.g.image_rendering_enabled = true
          end

          if vim.g.image_rendering_enabled then
            -- Disable rendering
            image.clear()
            vim.g.image_rendering_enabled = false
            vim.notify("Image rendering disabled", vim.log.levels.INFO)
          else
            -- Enable rendering - need to re-setup and render
            image.setup()
            -- Force re-render by triggering buffer reload
            vim.cmd("edit")
            vim.g.image_rendering_enabled = true
            vim.notify("Image rendering enabled", vim.log.levels.INFO)
          end
        end,
        desc = "Toggle image rendering",
      },
    },
  },
  {
    "hakonharnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      -- add options here
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  }
}
