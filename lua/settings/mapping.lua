local map = vim.keymap.set
local wk = require 'which-key'

-- ############################################
-- Helper functions
-- ############################################

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
local function mark_terminal()
  local job_id = vim.b.terminal_job_id
  vim.print('job_id: ' .. job_id)
end

local function set_terminal()
  vim.fn.call('slime#config', {})
end

local image = require 'image'
local function clear_all_images()
  local bufnr = vim.api.nvim_get_current_buf()
  local images = image.get_images { buffer = bufnr }
  for _, img in ipairs(images) do
    img:clear()
  end
end

local function get_image_at_cursor(buf)
  local images = image.get_images { buffer = buf }
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  for _, img in ipairs(images) do
    if img.geometry ~= nil and img.geometry.y == row then
      local og_max_height = img.global_state.options.max_height_window_percentage
      img.global_state.options.max_height_window_percentage = nil
      return img, og_max_height
    end
  end
  return nil
end

local create_preview_window = function(img, og_max_height)
  local buf = vim.api.nvim_create_buf(false, true)
  local win_width = vim.api.nvim_get_option_value('columns', {})
  local win_height = vim.api.nvim_get_option_value('lines', {})
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    style = 'minimal',
    width = win_width,
    height = win_height,
    row = 0,
    col = 0,
    zindex = 1000,
  })
  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win, true)
    img.global_state.options.max_height_window_percentage = og_max_height
  end, { buffer = buf })
  return { buf = buf, win = win }
end

local handle_zoom = function(bufnr)
  local img, og_max_height = get_image_at_cursor(bufnr)
  if img == nil then
    return
  end

  local preview = create_preview_window(img, og_max_height)
  image.hijack_buffer(img.path, preview.win, preview.buf)
end

-- ############################################
-- Mappings
-- ############################################
map("n", "<leader>q", ":q!<CR>", { desc = "force quit" })
map("n", "<leader>s", ":w<CR>", { desc = "save" })

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
map("n", "<leader>cc", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>cc", "gc", { desc = "Toggle comment", remap = true })

-- Code mappings
map("n", "<leader>c<cr>", send_cell, { desc = "Send code cell" })
map("v", "<leader>c<cr>", send_region, { desc = "Send code region" })

map("n", "<leader>Tp", new_terminal_python, { desc = "New python terminal" })
map("n", "<leader>Ti", new_terminal_ipython, { desc = "New ipython terminal" })
map("n", "<leader>Ts", new_terminal_shell, { desc = "New shell terminal" })

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local function lspmap(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    local function lspvmap(keys, func, desc)
      vim.keymap.set('v', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    assert(client, 'LSP client not found')

    ---@diagnostic disable-next-line: inject-field
    client.server_capabilities.document_formatting = true

    lspmap('<leader>cS', vim.lsp.buf.document_symbol, 'go so symbols')
    lspmap('<leader>cT', vim.lsp.buf.type_definition, 'go to type definition')
    lspmap('<leader>ct', vim.lsp.buf.definition, 'go to definition')
    lspmap('<leader>ck', vim.lsp.buf.hover, 'hover documentation')
    lspmap('<leader>ch', vim.lsp.buf.signature_help, 'go to signature help')
    lspmap('<leader>ci', vim.lsp.buf.implementation, 'go to Implementation')
    lspmap('<leader>cdp', function() vim.diagnostic.jump({ count = 1 }) end, 'previous diagnostic ')
    lspmap('<leader>cdn', function() vim.diagnostic.jump({ count = -1 }) end, 'next diagnostic ')
    lspmap('<leader>cl', vim.lsp.codelens.run, 'lens run')
    lspmap('<leader>cr', vim.lsp.buf.rename, 'lsp rename')
    lspmap('<leader>cf', vim.lsp.buf.format, 'lsp format')
    lspvmap('<leader>cf', vim.lsp.buf.format, 'lsp format')
    lspmap('<leader>cq', vim.diagnostic.setqflist, 'lsp diagnostic quickfix')
    lspmap("<leader>cdd", function() vim.diagnostic.enable(false) end, "Disable diagnostics")
    lspmap("<leader>cde", vim.diagnostic.enable, "Enable diagnostics")
    lspmap("<leader>ce", vim.diagnostic.open_float, "Diagnostics (show hover error)")

    lspmap("<leader>cD", "<cmd>Telescope diagnostics<cr>", "Pick diagnostics")
    lspmap("<leader>cS", "<cmd>Telescope lsp_document_symbols<cr>", "Pick symbols is document")
    lspmap("<leader>cR", "<cmd>Telescope lsp_references<cr>", "Pick references")
    lspmap("<leader>ca", vim.lsp.buf.code_action, "Pick code actions")
    lspmap("<leader>cI", "<cmd>Telescope lsp_incoming_calls<cr>", "Pick incoming calls")
    lspmap("<leader>cO", "<cmd>Telescope lsp_outgoing_calls<cr>", "Pick outgoing calls")
  end,
})


-- Telescope mappings
map("n", "<leader>v", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>g", "<cmd>Telescope live_grep<cr>", { desc = "Find string in files" })
map("n", "<leader>fv", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Find string in files" })
map("n", "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find in buffer" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Find help tags" })
map("n", "<leader>fM", "<cmd>Telescope marks<cr>", { desc = "Find marks" })
map("n", "<leader>fl", "<cmd>Telescope loclist<cr>", { desc = "Find loclist" })
map("n", "<leader>fq", "<cmd>Telescope quickfix<cr>", { desc = "Find quickfix" })
map("n", "<leader>fr", "<cmd>Telescope resume<cr>", { desc = "Resume last telescope" })
map("n", "<leader>ft", "<cmd>Telescope treesitter<cr>", { desc = "Find treesitter" })
map("n", "<leader>fT", "<cmd>TodoTelescope<cr>", { desc = "List TODOs" })
map("n", "<leader>fG", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor" })
map("n", "<leader>fc", "<cmd>Telescope commands <cr>", { desc = "Pick neovim command" })
map("n", "<leader>fC", "<cmd>Telescope<cr>", { desc = "Telescope Commands" })
map("n", "<leader>fm", "<cmd>Telescope man_pages<cr>", { desc = "Find manpage" })
map("n", "<leader>fs", "<cmd>Telescope spell_suggest<cr>", { desc = "Find spelling suggestions" })
map("v", "<leader>fg", "<cmd>Telescope grep_string<cr>", { desc = "Find string in files" })
map("v", "<leader>fC", "<cmd>Telescope<cr>", { desc = "Telescope Commands" })


-- help mappings
map("n", "<leader>hch", ":set conceallevel=1<CR>", { desc = "Hide conceal" })
map("n", "<leader>hcs", ":set conceallevel=0<CR>", { desc = "Show conceal" })
map("n", "<leader>ht", vim.treesitter.inspect_tree, { desc = "Inspect treesitter" })
map("n", "<leader>d", "<cmd>vsplit<cr> <cmd>Oil<cr>", { desc = "Oil: edit filesystem" })


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

-- send code with ctrl+Enter
-- just like in e.g. RStudio
-- needs kitty (or other terminal) config:
-- map shift+enter send_text all \x1b[13;2u
-- map ctrl+enter send_text all \x1b[13;5u
map("n", "<c-cr>", send_cell, { desc = "run code cell" })
map("n", "<s-cr>", send_cell, { desc = "run code cell" })
map("i", "<c-cr>", send_cell, { desc = "run code cell" })
map("i", "<s-cr>", send_cell, { desc = "run code cell" })

-- keep selection after indent/dedent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- center after search and jumps
map("n", 'n', 'nzz')
map("n", '<c-d>', '<c-d>zz')
map("n", '<c-u>', '<c-u>zz')


-- notebook mappings

map("n", "<leader>nE", function() require('otter').export(true) end, { desc = "Export quarto with overwrite" })
map("n", "<leader>na", require 'otter'.activate, { desc = "Activate otter" })
map("n", "<leader>nb", insert_bash_chunk, { desc = "Insert bash chunk" })
map("n", "<leader>nd", require 'otter'.activate, { desc = "Deactivate otter" })
map("n", "<leader>ne", require('otter').export, { desc = "Export quarto" })
map("n", "<leader>nh", ":QuartoHelp ", { desc = "Quarto help" })
map("n", "<leader>np", insert_py_chunk, { desc = "Insert python chunk" })
map("n", "<leader>nq", ":QuartoActivate<cr>", { desc = "Activate quarto" })
map("n", "<leader>nra", ":QuartoSendAll<cr>", { desc = "Quarto run all" })
map("n", "<leader>nrb", ":QuartoSendBelow<cr>", { desc = "Quarto run below" })
map("n", "<leader>nrr", ":QuartoSendAbove<cr>", { desc = "Quarto run above" })
map("n", "<leader>nrp", ":lua require'quarto'.quartoPreview()<cr>", { desc = "Preview quarto" })
map("n", "<leader>nrq", ":lua require'quarto'.quartoClosePreview()<cr>", { desc = "Quiet preview quarto" })
map("n", "<leader>nM", function() require("nabla").toggle_virt() end, { desc = "Toggle math equations" })
map('n', '<leader>ntm', mark_terminal, { desc = 'mark terminal' })
map('n', '<leader>nts', set_terminal, { desc = 'set terminal' })

-- todo comments mappings
map("n", "<leader>tn", function() require("todo-comments").jump_next() end, { desc = "Next Todo Comment" })
map("n", "<leader>tp", function() require("todo-comments").jump_prev() end, { desc = "Previous Todo Comment" })
map("n", "<leader>tt", ":TodoTelescope<cr>", { desc = "Todo" })
map("n", "<leader>ta", ":TodoTelescope keywords=TODO,FIX,FIXME<cr>", { desc = "Todo/Fix/Fixme" })


-- normal mode with <leader>
wk.add({
  {
    { "<leader>c",  group = "code/lsp actions" },
    { "<leader>dt", group = "test" },
    { "<leader>e",  group = "edit" },
    { "<leader>f",  group = "telescope" },
    { "<leader>h",  group = "help" },
    { "<leader>hc", group = "conceal" },
    { "<leader>cd", group = "diagnostics" },
    { "<leader>n",  group = "notebook" },
    { "<leader>nr", group = "run" },
    { "<leader>nt", group = "terminal" },
    { "<leader>t",  group = "todo" },
    { "<leader>T",  group = "terminal" },
    { "<leader>w",  group = "windows" },
  }
}, { mode = 'n' })
