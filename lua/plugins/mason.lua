return {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
	    "neovim/nvim-lspconfig",
    },
    config = function()
      local lspconfig = require('lspconfig')
      require("mason").setup()

      require("mason-lspconfig").setup({
          automatic_installation = true,
          ensure_installed = {
            "jsonls",
            "pyright",
            "zls",
            "clangd",
            "rust_analyzer",
            "lua_ls",
            "bashls",
          },
      })

      require("mason-tool-installer").setup({
          ensure_installed = {
              "prettier",
              "stylua", -- lua formatter
              "black", -- python formatter
              "pylint",
          },
      })

      require('mason-lspconfig').setup_handlers({
        function(server)
          lspconfig[server].setup({})
        end,
      })
    end,
}
