vim.g.mapleader = " "

local Plug = vim.fn["plug#"]

vim.call("plug#begin")
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim")
vim.call("plug#end")

vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<CR>")
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<CR>")
