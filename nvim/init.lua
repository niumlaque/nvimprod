vim.g.mapleader = " "

local Plug = vim.fn["plug#"]

vim.call("plug#begin")
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim")
Plug("tomasr/molokai")
vim.call("plug#end")

vim.cmd.colorscheme("molokai")
vim.api.nvim_set_hl(0, "MatchParen", {
    bold = true,
    fg = "#ff8700",
    bg = "#121212",
})
vim.api.nvim_set_hl(0, "StatusLine", {
    bg = "#161616",
})

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
if vim.fn.has("win32") == 0 then
    vim.g.clipboard = "xsel"
end
vim.opt.clipboard:append("unnamedplus")

local rust_metadata_cache = {}
local rustfmt_skip_once = {}

local function file_mtime(path)
    local stat = vim.uv.fs_stat(path)
    if stat == nil then
        return nil
    end

    return stat.mtime.sec .. ":" .. stat.mtime.nsec
end

local function get_rust_metadata(file_path)
    local manifest_path = vim.fs.find("Cargo.toml", {
        path = vim.fs.dirname(file_path),
        upward = true,
    })[1]

    if manifest_path == nil then
        error("rustfmt: Cargo.toml not found", 0)
    end

    manifest_path = vim.fs.normalize(manifest_path)

    local cached = rust_metadata_cache[manifest_path]
    if cached ~= nil
        and file_mtime(cached.manifest_path) == cached.manifest_mtime
        and file_mtime(cached.workspace_manifest_path) == cached.workspace_manifest_mtime
    then
        return cached
    end

    local result = vim.system({
        "cargo",
        "metadata",
        "--format-version",
        "1",
        "--no-deps",
        "--manifest-path",
        manifest_path,
    }, {
        cwd = vim.fs.dirname(manifest_path),
        text = true,
    }):wait()

    if result.code ~= 0 then
        error("cargo metadata failed: " .. vim.trim(result.stderr or ""), 0)
    end

    local ok, metadata = pcall(vim.json.decode, result.stdout)
    if not ok then
        error("cargo metadata returned invalid JSON", 0)
    end

    local package
    for _, candidate in ipairs(metadata.packages) do
        if vim.fs.normalize(candidate.manifest_path) == manifest_path then
            package = candidate
            break
        end
    end

    if package == nil then
        error("rustfmt: package not found in cargo metadata", 0)
    end

    local package_manifest_path = vim.fs.normalize(package.manifest_path)
    local workspace_manifest_path =
        vim.fs.normalize(vim.fs.joinpath(metadata.workspace_root, "Cargo.toml"))

    local package_manifest_mtime = file_mtime(package_manifest_path)
    local workspace_manifest_mtime = file_mtime(workspace_manifest_path)

    if package_manifest_mtime == nil or workspace_manifest_mtime == nil then
        error("rustfmt: failed to read Cargo.toml metadata", 0)
    end

    local entry = {
        edition = package.edition,
        manifest_path = package_manifest_path,
        manifest_mtime = package_manifest_mtime,
        workspace_manifest_path = workspace_manifest_path,
        workspace_manifest_mtime = workspace_manifest_mtime,
    }

    rust_metadata_cache[manifest_path] = entry
    return entry
end

local function rustfmt_buffer(buf)
    local file_path = vim.api.nvim_buf_get_name(buf)
    local metadata = get_rust_metadata(file_path)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    local result = vim.system({
        "rustfmt",
        "--edition",
        metadata.edition,
    }, {
        cwd = vim.fs.dirname(file_path),
        stdin = lines,
        text = true,
    }):wait()

    if result.code ~= 0 then
        error("rustfmt failed: " .. vim.trim(result.stderr or ""), 0)
    end

    local formatted = vim.split(result.stdout or "", "\n", { plain = true })

    if formatted[#formatted] == "" then
        table.remove(formatted)
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted)
end

local rustfmt_group =
    vim.api.nvim_create_augroup("NvimprodRustfmt", { clear = true })

-- :save / :saveas changes the buffer name before writing.
-- Mark that write so BufWritePre can skip rustfmt.
vim.api.nvim_create_autocmd("BufFilePre", {
    group = rustfmt_group,
    callback = function(args)
        rustfmt_skip_once[args.buf] = true

        vim.schedule(function()
            rustfmt_skip_once[args.buf] = nil
        end)
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = rustfmt_group,
    callback = function(args)
        if vim.bo[args.buf].filetype ~= "rust" then
            return
        end

        if rustfmt_skip_once[args.buf] then
            rustfmt_skip_once[args.buf] = nil
            return
        end

        rustfmt_buffer(args.buf)
    end,
})
