return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason").setup()

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using
              -- (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = {
                'vim',
                'require',
              },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file('', true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "jsonls",
          "pyright",
          "zls",
          "clangd",
          "lua_ls",
          "bashls",
          "denols",
        },
      })

      require("mason-tool-installer").setup({
        ensure_installed = {
          "prettier",
          "stylua", -- lua formatter
          "black",  -- python formatter
          "pylint",
        },
      })
    end,
  }
}
