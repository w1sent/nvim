return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-textobjects",
  },
  config = function()
    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
      autotag = {
        enable = true,
      },
      ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "zig",
        "cpp",
        "asm",
        "tsx",
        "yaml",
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "bash",
        "python",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "c",
        "ocaml",
        "go",
        "llvm",
        "toml",
        "xml",
        "asm",
        "dot",
        "mermaid",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      rainbow = {
        enable = true,
        disable = { "html" },
        extended_mode = false,
        max_file_lines = nil,
      },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
    })
  end,
}
