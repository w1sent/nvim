local map = vim.keymap.set
local wk = require 'which-key'

local nmap = function(key, effect)
  vim.keymap.set('n', key, effect, { silent = true, noremap = true })
end

local vmap = function(key, effect)
  vim.keymap.set('v', key, effect, { silent = true, noremap = true })
end

local imap = function(key, effect)
  vim.keymap.set('i', key, effect, { silent = true, noremap = true })
end

local cmap = function(key, effect)
  vim.keymap.set('c', key, effect, { silent = true, noremap = true })
end


map("n", "<leader>q", ":q!<CR>", {})
map("n", "<leader>s", ":w<CR>", {})

-- Window managment
map("n", "<leader>wh", "<C-w>h", { desc = "switch window left" })
map("n", "<leader>wj", "<C-w>l", { desc = "switch window right" })
map("n", "<leader>wk", "<C-w>k", { desc = "switch window up" })
map("n", "<leader>wl", "<C-w>j", { desc = "switch window down" })
map("n", "<leader>w<left>", "<C-w>h", { desc = "switch window left" })
map("n", "<leader>w<right>", "<C-w>l", { desc = "switch window right" })
map("n", "<leader>w<up>", "<C-w>k", { desc = "switch window up" })
map("n", "<leader>w<down>", "<C-w>j", { desc = "switch window down" })
map("n", "<leader>wn", "<C-w>n", { desc = "create window horizontal" })
map("n", "<leader>wv", "<C-w>v", { desc = "create window vertical" })

-- Comment
map("n", "<leader>c", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>c", "gc", { desc = "Toggle comment", remap = true })

-- LSP-Functions
map("n", "<leader>D", ":lua vim.lsp.buf.declaration()<CR>", { desc = "Jump to declaration", remap = true })
map("n", "<leader>d", ":lua vim.lsp.buf.definition()<CR>", { desc = "Jump to definition", remap = true })
map("n", "<leader>k", ":lua vim.lsp.buf.hover()<CR>", { desc = "Show documentation", remap = true })
map("n", "<leader>a", ":lua vim.lsp.buf.code_action()<CR>", { desc = "perform code action", remap = true })
map("n", "<leader>r", ":lua vim.lsp.buf.rename()<CR>", { desc = "rename symbol", remap = true })
map("n", "<leader>F", ":lua conform.format()<CR>", { desc = "Format document", remap = true })

-- Terminal
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
--- TODO: incorpoarate this into quarto-nvim plugin
--- such that QuartoRun functions get the same capabilities
--- TODO: figure out bracketed paste for reticulate python repl.
local function send_cell()
  if vim.b['quarto_is_r_mode'] == nil then
    vim.fn['slime#send_cell']()
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.fn['slime#send_cell']()
  end
end

--- Send code to terminal with vim-slime
--- If an R terminal has been opend, this is in r_mode
--- and will handle python code via reticulate when sent
--- from a python chunk.
local slime_send_region_cmd = ':<C-u>call slime#send_op(visualmode(), 1)<CR>'
slime_send_region_cmd = vim.api.nvim_replace_termcodes(slime_send_region_cmd, true, false, true)
local function send_region()
  -- if filetyps is not quarto, just send_region
  if vim.bo.filetype ~= 'quarto' or vim.b['quarto_is_r_mode'] == nil then
    vim.cmd('normal' .. slime_send_region_cmd)
    return
  end
  if vim.b['quarto_is_r_mode'] == true then
    vim.g.slime_python_ipython = 0
    local is_python = require('otter.tools.functions').is_otter_language_context 'python'
    if is_python and not vim.b['reticulate_running'] then
      vim.fn['slime#send']('reticulate::repl_python()' .. '\r')
      vim.b['reticulate_running'] = true
    end
    if not is_python and vim.b['reticulate_running'] then
      vim.fn['slime#send']('exit' .. '\r')
      vim.b['reticulate_running'] = false
    end
    vim.cmd('normal' .. slime_send_region_cmd)
  end
end

-- send code with ctrl+Enter
-- just like in e.g. RStudio
-- needs kitty (or other terminal) config:
-- map shift+enter send_text all \x1b[13;2u
-- map ctrl+enter send_text all \x1b[13;5u
nmap('<c-cr>', send_cell)
nmap('<s-cr>', send_cell)
imap('<c-cr>', send_cell)
imap('<s-cr>', send_cell)

--- Show R dataframe in the browser
-- might not use what you think should be your default web browser
-- because it is a plain html file, not a link
-- see https://askubuntu.com/a/864698 for places to look for
local function show_r_table()
  local node = vim.treesitter.get_node { ignore_injections = false }
  assert(node, 'no symbol found under cursor')
  local text = vim.treesitter.get_node_text(node, 0)
  local cmd = [[call slime#send("DT::datatable(]] .. text .. [[)" . "\r")]]
  vim.cmd(cmd)
end

-- keep selection after indent/dedent
vmap('>', '>gv')
vmap('<', '<gv')

-- center after search and jumps
nmap('n', 'nzz')
nmap('<c-d>', '<c-d>zz')
nmap('<c-u>', '<c-u>zz')

--- Insert code chunk of given language
--- Splits current chunk if already within a chunk
--- @param lang string
local insert_code_chunk = function(lang)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>', true, false, true), 'n', true)
  local keys
  if is_code_chunk() then
    keys = [[o```<cr><cr>```{]] .. lang .. [[}<esc>o]]
  else
    keys = [[o```{]] .. lang .. [[}<cr>```<esc>O]]
  end
  keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

local insert_py_chunk = function()
  insert_code_chunk 'python'
end

local insert_bash_chunk = function()
  insert_code_chunk 'bash'
end


local function new_terminal(lang)
  vim.cmd('vsplit term://' .. lang)
end

local function new_terminal_python()
  new_terminal 'python'
end

local function new_terminal_ipython()
  new_terminal 'ipython --no-confirm-exit'
end

local function new_terminal_shell()
  new_terminal '$SHELL'
end

-- normal mode with <leader>
wk.add({
  {
    { "<leader><cr>", send_cell,                                       desc = "run code cell" },
    { "<leader>c",    group = "[c]ode / [c]ell / [c]hunk" },
    { "<leader>ci",   new_terminal_ipython,                            desc = "new [i]python terminal" },
    { "<leader>cn",   new_terminal_shell,                              desc = "[n]ew terminal with shell" },
    { "<leader>cp",   new_terminal_python,                             desc = "new [p]ython terminal" },
    { "<leader>d",    group = "[d]ebug" },
    { "<leader>dt",   group = "[t]est" },
    { "<leader>e",    group = "[e]dit" },
    { "<leader>f",    group = "[f]ind (telescope)" },
    { "<leader>fM",   "<cmd>Telescope man_pages<cr>",                  desc = "[M]an pages" },
    { "<leader>fb",   "<cmd>Telescope current_buffer_fuzzy_find<cr>",  desc = "[b]uffer fuzzy find" },
    { "<leader>fc",   "<cmd>Telescope git_commits<cr>",                desc = "git [c]ommits" },
    { "<leader>fd",   "<cmd>Telescope buffers<cr>",                    desc = "[d] buffers" },
    { "<leader>ff",   "<cmd>Telescope find_files<cr>",                 desc = "[f]iles" },
    { "<leader>fg",   "<cmd>Telescope live_grep<cr>",                  desc = "[g]rep" },
    { "<leader>fh",   "<cmd>Telescope help_tags<cr>",                  desc = "[h]elp" },
    { "<leader>fj",   "<cmd>Telescope jumplist<cr>",                   desc = "[j]umplist" },
    { "<leader>fk",   "<cmd>Telescope keymaps<cr>",                    desc = "[k]eymaps" },
    { "<leader>fl",   "<cmd>Telescope loclist<cr>",                    desc = "[l]oclist" },
    { "<leader>fm",   "<cmd>Telescope marks<cr>",                      desc = "[m]arks" },
    { "<leader>fq",   "<cmd>Telescope quickfix<cr>",                   desc = "[q]uickfix" },
    { "<leader>h",    group = "[h]elp / [h]ide / debug" },
    { "<leader>hc",   group = "[c]onceal" },
    { "<leader>hch",  ":set conceallevel=1<cr>",                       desc = "[h]ide/conceal" },
    { "<leader>hcs",  ":set conceallevel=0<cr>",                       desc = "[s]how/unconceal" },
    { "<leader>ht",   group = "[t]reesitter" },
    { "<leader>htt",  vim.treesitter.inspect_tree,                     desc = "show [t]ree" },
    { "<leader>i",    group = "[i]mage" },
    { "<leader>l",    group = "[l]anguage/lsp" },
    { "<leader>ld",   group = "[d]iagnostics" },
    { "<leader>ldd",  function() vim.diagnostic.enable(false) end,     desc = "[d]isable" },
    { "<leader>lde",  vim.diagnostic.enable,                           desc = "[e]nable" },
    { "<leader>le",   vim.diagnostic.open_float,                       desc = "diagnostics (show hover [e]rror)" },
    { "<leader>o",    group = "[o]tter & c[o]de" },
    { "<leader>oa",   require 'otter'.activate,                        desc = "otter [a]ctivate" },
    { "<leader>ob",   insert_bash_chunk,                               desc = "[b]ash code chunk" },
    { "<leader>od",   require 'otter'.activate,                        desc = "otter [d]eactivate" },
    { "<leader>op",   insert_py_chunk,                                 desc = "[p]ython code chunk" },
    { "<leader>q",    group = "[q]uarto" },
    { "<leader>qE",   function() require('otter').export(true) end,    desc = "[E]xport with overwrite" },
    { "<leader>qa",   ":QuartoActivate<cr>",                           desc = "[a]ctivate" },
    { "<leader>qe",   require('otter').export,                         desc = "[e]xport" },
    { "<leader>qh",   ":QuartoHelp ",                                  desc = "[h]elp" },
    { "<leader>qp",   ":lua require'quarto'.quartoPreview()<cr>",      desc = "[p]review" },
    { "<leader>qq",   ":lua require'quarto'.quartoClosePreview()<cr>", desc = "[q]uiet preview" },
    { "<leader>qr",   group = "[r]un" },
    { "<leader>qra",  ":QuartoSendAll<cr>",                            desc = "run [a]ll" },
    { "<leader>qrb",  ":QuartoSendBelow<cr>",                          desc = "run [b]elow" },
    { "<leader>qrr",  ":QuartoSendAbove<cr>",                          desc = "to cu[r]sor" },
    { "<leader>x",    group = "e[x]ecute" },
  }
}, { mode = 'n' })
