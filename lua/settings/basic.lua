local global = vim.g
local o = vim.opt

-- NEOVIM Editor config
o.number = true
o.relativenumber = true
o.syntax = "on"
o.autoindent = true
o.cursorline = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.encoding = "UTF-8"
o.mouse = "a"
o.wildmenu = true
o.termguicolors = true

o.listchars = {
  tab = "┊ ",
  trail = "·",
  extends = "»",
  precedes = "«",
  nbsp = "×"
}

o.backup = false
o.swapfile = false

o.clipboard = "unnamedplus"
o.formatoptions:remove "o"
o.inccommand = "split"

-- Performance
o.history = 100
o.redrawtime = 1500
o.timeoutlen = 250
o.ttimeoutlen = 10
o.updatetime = 100

-- persistent undo
local undodir = vim.fn.stdpath("data") .. "/undo"
o.undofile = true -- enable persistent undo
o.undodir = undodir
o.undolevels = 1000
o.undoreload = 10000

global.mapleader = " "

-- Spellchecking configuration
o.spell = true
o.spelllang = { "en", "de", "fr" }
o.spelloptions = "camel"

vim.cmd([[
      set completeopt=menuone,noinsert,noselect
      highlight! default link CmpItemKind CmpItemMenuDefault
    ]])

-- Disable builtin plugins
-- Note: netrw and spellfile_plugin are conditionally disabled by the spell module
local disabled_built_ins = {
  "2html_plugin", "getscript", "getscriptPlugin", "gzip", "logipat",
  "matchit", "tar", "tarPlugin", "rrhelper",
  "vimball", "vimballPlugin", "zip", "zipPlugin", "tutor", "rplugin",
  "synmenu", "optwin", "compiler", "bugreport", "ftplugin"
}

for _, plugin in pairs(disabled_built_ins) do
  global["loaded_" .. plugin] = 1
end
