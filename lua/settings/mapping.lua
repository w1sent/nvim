local map = vim.keymap.set

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
map("n", "<leader>d", ":vim.diagnostic.open_float()<CR>", { desc = "Show diagnostic", remap = true })
map("n", "<leader>k", ":vim.buf.hover()<CR>", { desc = "Show documentation", remap = true })
map("n", "<leader>a", ":vim.buf.code_action()<CR>", { desc = "perform code action", remap = true })
map("n", "<leader>r", ":vim.buf.rename()<CR>", { desc = "rename symbol", remap = true })

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
