return {
  {
    'stevearc/overseer.nvim',
    lazy = true,
    cmd = { "OverseerOpen", "OverseerClose", "OverseerToggle",
      "OverseerSaveBundle", "OverseerLoadBundle", "OverseerDeleteBundle",
      "OverseerRunCmd", "OverseerRun", "OverseerInfo", "OverseerBuild",
      "OverseerQuickAction", "OverseerTaskAction" },
    opts = {},
  },
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {--[[ things you want to change go here]]},
  },
  {
  "olimorris/codecompanion.nvim",
    opts = {},
    lazy = true,
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionCmd",
      "CodeCompanionActions" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" }
  },
}

