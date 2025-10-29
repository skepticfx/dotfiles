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
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  { "lewis6991/gitsigns.nvim" },
  { "akinsho/bufferline.nvim", config = function() 
     local bufferline = require("bufferline")
     bufferline.setup()
   end
   },
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


vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client.server_capabilities.completionProvider then
      -- enable built-in LSP completion for this buffer
      vim.lsp.completion.enable(true, client.id, ev.buf)
    end

    -- manual fallback using omnifunc (no trigger() API in 0.11 stable)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { buffer = ev.buf, desc = "Trigger completion" })
  end,
})

-- nice completion menu behavior
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append("c")

-- Auto trigger completion as you type (Neovim 0.11 stable)
vim.api.nvim_create_autocmd("TextChangedI", {
  callback = function()
    local col = vim.fn.col(".")
    if col > 1 then
      local ch = vim.fn.getline("."):sub(col - 1, col - 1)
      -- trigger after ., >, ", ', /
      if ch:match("[%.>%\"'/]") then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, true, true), "n")
      end
    end
  end,
})

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
