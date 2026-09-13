vim.g.mapleader = " "

local Plug = vim.fn["plug#"]

vim.call("plug#begin")
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim")
Plug("tomasr/molokai")
vim.call("plug#end")

vim.cmd.colorscheme("molokai")
vim.cmd("filetype plugin indent on")

vim.opt.number = true
vim.opt.undofile = true
vim.opt.wrapscan = false
vim.opt.display:append("uhex")

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.smartindent = true

vim.api.nvim_create_autocmd("FileType", {
    pattern = "javascript",
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.softtabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<CR>")
vim.keymap.set("n", "<leader>b", "<cmd>Telescope buffers<CR>")

vim.keymap.set({ "n", "v", "o" }, "<C-h>", "0")
vim.keymap.set({ "n", "v", "o" }, "<C-l>", "$")

vim.keymap.set("n", ",/", "gcc", { remap = true, silent = true })
vim.keymap.set("v", ",/", "gc", { remap = true, silent = true })

local function status_file_info()
    local encoding = vim.bo.fileencoding
    if encoding == "" then
        encoding = vim.o.encoding
    end

    local file_formats = {
        dos = "CR+LF",
        unix = "LF",
        mac = "CR",
    }

    local file_format = file_formats[vim.bo.fileformat] or vim.bo.fileformat

    return "[" .. encoding .. "][" .. file_format .. "]"
end

_G.nvimprod_status_file_info = status_file_info

vim.opt.statusline =
    "%<%F%=%m%r%h%w%{v:lua.nvimprod_status_file_info()} %l,%c"

vim.opt.mouse = ""
vim.opt.clipboard:append("unnamedplus")
