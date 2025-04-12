
vim.keymap.set("n", "<leader>i", "miHmtgg=G'ti", { noremap = true, silent = true })

-- Experiments
-- Bootstrap lazy.nvim for plugin management
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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
  { "neovim/nvim-lspconfig", config = function()
    local lspconfig = require("lspconfig")
    local fzf = require("fzf-lua")
    lspconfig.ts_ls.setup({ filetypes = { "typescript", "javascript" } })
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
	vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "Find definitions" })
	vim.keymap.set("n", "gr", fzf.lsp_references, { desc = "Find references" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
      end,
    })
  end },
  { "ibhagwan/fzf-lua", config = function()
    local fzf = require("fzf-lua")
    vim.keymap.set("n", "<leader>b", fzf.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>B", fzf.builtin, { desc = "Builtins" })
    vim.keymap.set("n", "<leader>f", function()
    	fzf.files({ cwd_prompt = true })
    end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>g", fzf.grep_curbuf, { desc = "Search in file" })
    vim.keymap.set("n", "<leader>G", fzf.live_grep, { desc = "Search in project" })
    vim.keymap.set("n", "<leader>r", fzf.registers, { desc = "select registers" })
  end },
})

-- end experiments

-- basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true

-- themes
vim.cmd("colorscheme retrobox")

-- keymaps
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
