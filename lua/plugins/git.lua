return {
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    keys = {
      { "<leader>Gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
      { "<leader>Gc", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
      { "<leader>Gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: file history (current)" },
      { "<leader>Gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: file history (all)" },
      {
        "<leader>Gs",
        function()
          -- Use telescope to select a file and show its history
          require("telescope.builtin").git_files({
            attach_mappings = function(_, map)
              map("i", "<CR>", function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                if selection then
                  vim.cmd("DiffviewFileHistory " .. selection.value)
                end
              end)
              map("n", "<CR>", function(prompt_bufnr)
                local selection = require("telescope.actions.state").get_selected_entry()
                require("telescope.actions").close(prompt_bufnr)
                if selection then
                  vim.cmd("DiffviewFileHistory " .. selection.value)
                end
              end)
              return true
            end,
          })
        end,
        desc = "Diffview: file history (telescope select)",
      },
      {
        "<leader>Gf",
        ":'<,'>DiffviewFileHistory<cr>",
        mode = "v",
        desc = "Diffview: file history (visual selection)",
      },
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
        use_icons = true,
      })
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>Gg", "<cmd>Neogit<cr>", desc = "Neogit: open" },
      { "<leader>GC", "<cmd>Neogit commit<cr>", desc = "Neogit: commit" },
      { "<leader>Gp", "<cmd>Neogit push<cr>", desc = "Neogit: push" },
      { "<leader>Gl", "<cmd>Neogit pull<cr>", desc = "Neogit: pull" },
    },
    config = function()
      require("neogit").setup({
        -- Use telescope for selections
        integrations = {
          telescope = true,
          diffview = true,
        },
        graph_style = "unicode",
      })
    end,
  },
}
