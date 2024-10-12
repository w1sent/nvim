local map = vim.keymap.set

map("n", "<leader>q", ":qa!<CR>", {})
map("n", "<leader>s", ":w<CR>", {})

-- Window managment
map("n", "<leader>wh", "<C-w>h", { desc = "switch window left" })
map("n", "<leader>wj", "<C-w>j", { desc = "switch window right" })
map("n", "<leader>wk", "<C-w>k", { desc = "switch window up" })
map("n", "<leader>wl", "<C-w>l", { desc = "switch window down" })
map("n", "<leader>wn", "<C-w>n", { desc = "create window horizontal" })
map("n", "<leader>wv", "<C-w>v", { desc = "create window vertical" })

-- Comment
map("n", "<leader>c", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<leader>c", "gc", { desc = "Toggle comment", remap = true })

-- Terminal
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
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
