local map = vim.keymap.set
local wk = require 'which-key'

-- ############################################
-- Helper functions
-- ############################################

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


-- keep selection after indent/dedent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- center after search and jumps
map("n", 'n', 'nzz')
map("n", '<c-d>', '<c-d>zz')
map("n", '<c-u>', '<c-u>zz')

-- zoekt mappings
map("n", "<leader>zz", ":Zoekt -index_dir ./.zoekt", { desc = "Search with Zoekt" })
map("n", "<leader>zr", ":ZoektRef<cr>", { desc = "Search references for the word under cursor with Zoekt" })
map("n", "<leader>zd", ":ZoektDef<cr>", { desc = "Search references for the word under cursor with Zoekt" })

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
    { "<leader>G",  group = "git" },
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
