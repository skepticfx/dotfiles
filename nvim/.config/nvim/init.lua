-- remap leader to space
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>i", "miHmtgg=G'ti", { noremap = true, silent = true })
vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch<CR>")
vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

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
    vim.keymap.set("n", "<leader>F", function()
      fzf.files({ cwd_prompt = true })
    end, { desc = "Find files (cwd)" })
    vim.keymap.set("n", "<leader>f", function()
      fzf.files({ cwd= vim.fn.expand("%:p:h") })
    end, { desc = "Find files" })
    vim.keymap.set("n", "<leader>g", fzf.grep_curbuf, { desc = "Search in buffer" })
    vim.keymap.set("n", "<leader>G", fzf.live_grep, { desc = "Search in project" })
    vim.keymap.set("n", "<leader>\"", fzf.registers, { desc = "select registers" })
    vim.keymap.set("n", "<leader>D", fzf.diagnostics_document, { desc = "buffer diagnostics" })
    vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "float the diagnostic under cursor" })
    vim.keymap.set("n", "<leader>c", fzf.changes, { desc = "changes" })
    vim.keymap.set("n", "<leader>r", fzf.lsp_references, { desc = "references" })
    vim.keymap.set("n", "<leader>R", vim.lsp.buf.rename, { desc = "Rename variable" })
    vim.keymap.set("n", "<leader>s", fzf.lsp_document_symbols, { desc = "buffer symbols" })
    vim.keymap.set("n", "<leader>d", fzf.lsp_definitions)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "<leader>vs", fzf.git_status)
    vim.keymap.set("n", "<leader>'", fzf.resume)
    vim.keymap.set("n", "<leader>E", vim.cmd.Explore)
    vim.keymap.set("n", "<leader>X", ":bd<CR>")
  end },
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
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },  -- Load early on any file open
    opts = {
      auto_attach = true,
      -- current_line_blame = true,  -- Shows blame info as virtual text on the current line
      current_line_blame_opts = {
        virt_text_pos = "eol",    -- Place at end of line (options: 'eol', 'overlay', 'right_align')
        delay = 500,              -- Optional: ms delay before showing (default 1000)
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",  -- Optional: customize format
    },
    keys = {
      {
        "gb",
        function()
          require("gitsigns").toggle_current_line_blame()
        end,
        desc = "Toggle git current line blame",
      },
    },
  },
  { "akinsho/bufferline.nvim", config = function() 
    local bufferline = require("bufferline")
    bufferline.setup()
  end
},
{
  'saghen/blink.cmp',
  version = '1.7.0',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'super-tab' },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = { documentation = { auto_show = false } },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
},
{ "tpope/vim-eunuch" },
{
  "rmagatti/auto-session",
  lazy = false,  -- ensures it loads at startup
  config = function()
    require("auto-session").setup(  {
      auto_restore = true,             -- restore session when reopening dir
      auto_save = true,                -- save automatically on exit
      auto_session_enabled = true,     -- make sure autosave is active
      auto_session_create_enabled = true,
      auto_session_enable_last_session = true,
      log_level = "info",
      session_lens = { load_on_setup = false },
      auto_restore_last_session = true,
    })
  end,
},
{
  'MagicDuck/grug-far.nvim',
  config = function()
    require('grug-far').setup({
    });
  end
},
-- color packages
{ "rebelot/kanagawa.nvim" },
{ "zootedb0t/citruszest.nvim" },
{ "craftzdog/solarized-osaka.nvim" },

-- code context breadcrumbs
{ "SmiteshP/nvim-navic", 
  dependencies = "nvim-treesitter/nvim-treesitter",
  config = function()
    require("nvim-navic").setup({
      icons = {
        File = "󰈙 ",
        Module = " ",
        Namespace = "󰌗 ",
        Package = " ",
        Class = "󰌗 ",
        Method = "󰆧 ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = "󰕘",
        Interface = "󰕘",
        Function = "󰊕 ",
        Variable = "󰆧 ",
        Constant = "󰏿 ",
        String = " ",
        Number = "󰎠 ",
        Boolean = "◩ ",
        Array = "󰅪 ",
        Object = "󰅩 ",
        Key = "󰌋 ",
        Null = "󰟢 ",
        EnumMember = " ",
        Struct = "󰌗 ",
        Event = " ",
        Operator = "󰆕 ",
        TypeParameter = "󰊄 ",
      },
      lsp = {
        auto_attach = false,  -- We'll attach manually
        preference = nil,
      },
      separator = " > ",
      highlight = true,
      click = false,
    })
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
vim.cmd("colorscheme solarized-osaka")

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

-- C/C++ LSP (clangd)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },  -- Add more if needed, e.g., "h", "hpp"
  callback = function()
    vim.lsp.start({
      name = "clangd",
      cmd = { "clangd", "--background-index" },  -- --background-index is useful for indexing projects
      root_dir = vim.fs.root(0, { "compile_commands.json", "compile_flags.txt", ".git" }),
      -- Optional: Some nice default settings
      capabilities = {
        offsetEncoding = "utf-16",  -- Helps with older Neovim versions, often recommended for clangd
      },
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.lsp.start({
      name = "gopls",
      cmd = { "gopls" },
      root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),
      settings = {
        gopls = {
          completeUnimported = true, -- show completions from unimported packages
          usePlaceholders = true,    -- placeholders for function parameters
          analyses = { unusedparams = true },
          staticcheck = true,
        },
      },
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
      settings = {
        typescript = {
          suggest = { autoImports = true },
        },
        javascript = {
          suggest = { autoImports = true },
        },
      },
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

-- End LSP stuff

-- -- Open FzfLua automatically if Neovim starts without files
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     if vim.fn.argc() == 0 then
--       require("fzf-lua").live_grep()
--     elseif vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
--       vim.cmd("cd " .. vim.fn.argv(0))
--       require("fzf-lua").files()
--     end
--   end,
-- })


-- User commands
vim.api.nvim_create_user_command("Cfn", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "Copy current filename to clipboard"})

-- Code context breadcrumbs setup
-- Attach navic to LSP clients
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, args.buf)
    end
  end,
})

-- Custom statusline with breadcrumbs
vim.o.laststatus = 3  -- Global statusline
vim.o.statusline = table.concat({
  " %f",                                          -- File path
  " %m",                                          -- Modified flag
  -- "%=",                                           -- Switch to right side
  " %l:%c ",                                      -- Line:Column
  "%{%v:lua.require'nvim-navic'.get_location()%}", -- Breadcrumbs
  " %p%% ",                                       -- Percentage through file
})
