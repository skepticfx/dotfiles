-- Disable netrw completely
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- remap leader to space
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>i", "miHmtgg=G'ti", { noremap = true, silent = true })

-- Experiments
-- Bootstrap lazy.nvim for plugin management
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local fzf

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "typescript", "javascript" },
      highlight = { enable = true },
    })
  end },

  { "ibhagwan/fzf-lua", config = function()
    fzf = require("fzf-lua")
    vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>B", fzf.builtin, { desc = "Builtins" })
    vim.keymap.set("n", "<leader>f", function()
      fzf.files({ cwd_prompt = true })
    end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>g", fzf.grep_curbuf, { desc = "Search in buffer" })
    vim.keymap.set("n", "<leader>G", fzf.live_grep, { desc = "Search in project" })
    vim.keymap.set("n", "<leader>\"", fzf.registers, { desc = "select registers" })
    vim.keymap.set("n", "<leader>d", fzf.diagnostics_document, { desc = "buffer diagnostics" })
    vim.keymap.set("n", "<leader>c", fzf.changes, { desc = "changes" })
    vim.keymap.set("n", "<leader>r", fzf.lsp_references, { desc = "references" })
    vim.keymap.set("n", "<leader>s", fzf.lsp_document_symbols, { desc = "buffer symbols" })
    vim.keymap.set("n", "<leader>d", fzf.lsp_definitions)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "<leader>vs", fzf.git_status)
  end },
  { "rebelot/kanagawa.nvim" },
})

-- end experiments

-- basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true

-- themes
vim.cmd("colorscheme kanagawa-wave")

-- keymaps
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })

-- indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- format on save 
vim.api.nvim_create_augroup("GoFmt", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.go",
  callback = function()
    vim.cmd("silent! !go fmt %")
  end,
  group = "GoFmt",
})

-- remap "+ to leader+
vim.keymap.set('n', '<leader>y"', 'vi"+y', { noremap = true, silent = true })


-- LSP stuff
-- Start LSPs automatically when relevant filetypes open

-- Go LSP
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.lsp.start({
      name = "gopls",
      cmd = { "gopls" },
      root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),
    })
  end,
})

-- TS/JS LSP
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "javascript", "json" },
  callback = function()
    vim.lsp.start({
      name = "typescript-language-server",
      cmd = { "typescript-language-server", "--stdio" },
      root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" }),
    })
  end,
})

-- Vimscript LSP
vim.api.nvim_create_autocmd("FileType", {
  pattern = "vim",
  callback = function()
    vim.lsp.start({
      name = "vimls",
      cmd = { "vim-language-server", "--stdio" },
      root_dir = vim.fs.root(0, { ".git" }),
    })
  end,
})

-- Lua LSP
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.lsp.start({
      name = "lua_ls",
      cmd = { "lua-language-server" },
      root_dir = vim.fs.root(0, { ".git", ".luarc.json", ".luarc.jsonc" }),
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    })
  end,
})

-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local buf = args.buf
--     local opts = { buffer = buf }
--   end,
-- })
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { desc = "Trigger completion" })

-- End LSP stuff



-- Open FzfLua automatically if Neovim starts without files
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      require("fzf-lua").live_grep()
    elseif vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.cmd("cd " .. vim.fn.argv(0))
      require("fzf-lua").files()
    end
  end,
})
