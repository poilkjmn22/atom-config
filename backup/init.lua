-- ~/.config/nvim/init.lua

-------------------------------------
-- 0. 现场环境适配 (确保灵州站 A6000 顺畅下载)
-------------------------------------
-- 强制插件下载走 Mac 代理
-- vim.env.HTTPS_PROXY = "http://192.168.4.100:7897"
-- vim.env.HTTP_PROXY = "http://192.168.4.100:7897"

local node_bin_path = vim.fn.expand('$HOME/.nvm/versions/node/v22.20.0/bin:')
vim.env.PATH = node_bin_path .. ':' .. vim.env.PATH

-------------------------------------
-- 1. 基础设置 (保留原版全部偏好)
-------------------------------------
vim.opt.compatible = false
vim.opt.backspace = 'indent,eol,start'
vim.opt.history = 1000
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.relativenumber = true -- 0.11+ 推荐
vim.opt.mouse = 'a'
vim.opt.encoding = 'utf-8'
vim.opt.termguicolors = true
vim.opt.clipboard = 'unnamedplus' -- Mac 系统剪贴板支持

-- 文件备份与持久化
vim.opt.backup = true
vim.opt.undofile = true
vim.opt.backupdir = vim.fn.stdpath('data') .. '/backup//'
vim.opt.undodir = vim.fn.stdpath('data') .. '/undo//'

-------------------------------------
-- 2. 复用关键原版 Vim 逻辑 & 快捷键
-------------------------------------
vim.cmd([[
  " 禁用方向键
  noremap <Up> <Nop>
  noremap <Down> <Nop>
  noremap <Left> <Nop>
  noremap <Right> <Nop>

  " 保持 JSX/TypeScript 原版色彩配置
  let g:vim_jsx_pretty_colorful_config = 1
  let g:jsx_ext_required = 0

  " 简写映射
  iab xtime <c-r>=strftime("%Y-%m-%d %H:%M:%S")<cr>
  iab xdate <c-r>=strftime("%Y-%m-%d")<cr>
]])

-------------------------------------
-- 3. 插件管理器 (Lazy.nvim) - 补全原有插件
-------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- 基础核心
  'neovim/nvim-lspconfig',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',

  -- UI 增强 (找回丢失的主题和图标)
  'nvim-tree/nvim-web-devicons',
  'nvim-lualine/lualine.nvim',
  'lewis6991/gitsigns.nvim',
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({ -- 恢复原版 Nvim-tree 详细配置
        view = { width = 35, side = "left" },
        renderer = { group_empty = true, icons = { glyphs = { folder = { arrow_closed = "▶", arrow_open = "▼" } } } },
        filters = { dotfiles = false }
      })
    end
  },

  -- 补全系统
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' }
  },

  -- 搜索 (恢复原版 Tab 逻辑)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {'nvim-lua/plenary.nvim'},
    config = function()
      local actions = require("telescope.actions")
      require('telescope').setup{
        defaults = {
          mappings = {
            i = { ["<CR>"] = actions.select_tab, ["<C-CR>"] = actions.select_default },
            n = { ["<CR>"] = actions.select_tab }
          }
        }
      }
    end
  },

  -- 语法与开发辅助
  'github/copilot.vim',
  'pangloss/vim-javascript',
  'maxmellon/vim-jsx-pretty',
  'peitalin/vim-jsx-typescript',
  { 'posva/vim-vue', ft = 'vue' },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { 'folke/trouble.nvim', dependencies = { 'nvim-tree/nvim-web-devicons' } },
  { "pmizio/typescript-tools.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
}, {
  install = { colorscheme = { "desert" } } -- 恢复原版 desert 主题
})

-------------------------------------
-- 4. LSP & 格式化逻辑 (修复 ts_ls 与 eslint)
-------------------------------------
local function setup_lsp()
  local lspconfig = require('lspconfig')
  local capabilities = require('cmp_nvim_lsp').default_capabilities()

  -- 核心：修复 tsserver 为 ts_ls，并优化 Volar
  local servers = {
    ts_ls = { 
      single_file_support = false,
      root_dir = lspconfig.util.root_pattern('tsconfig.json')
    },
    volar = {
      init_options = { vue = { hybridMode = true } }
    },
    eslint = { settings = { format = false } },
    lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
    html = {},
    cssls = {}
  }

  require("mason").setup()
  require("mason-lspconfig").setup({
    ensure_installed = { "ts_ls", "volar", "eslint", "html", "cssls", "lua_ls" },
    handlers = {
      function(server_name)
        local opts = servers[server_name] or {}
        opts.capabilities = capabilities
        lspconfig[server_name].setup(opts)
      end,
    }
  })

  -- 恢复原版自动保存格式化逻辑
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.js", "*.ts", "*.jsx", "*.tsx", "*.vue" },
    callback = function()
      vim.cmd("silent! EslintFixAll")
    end
  })
end

-------------------------------------
-- 5. 键位映射 (完全同步原版)
-------------------------------------
vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope live_grep<cr>')
vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
vim.keymap.set('n', 'K', vim.lsp.buf.hover)
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format)
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
vim.keymap.set('n', '<leader>t', '<cmd>NvimTreeToggle<CR>')
vim.keymap.set('n', '<leader>ll', '<cmd>TroubleToggle<cr>')
vim.keymap.set('n', '<leader>h', '<cmd>noh<cr>')

-------------------------------------
-- 6. UI & 启动逻辑 (恢复 Lualine 与 Desert)
-------------------------------------
vim.cmd('colorscheme desert')
require('lualine').setup({ options = { theme = 'auto' } })

-- 模拟原版 User LazyVimStarted 流程保证加载顺序
setup_lsp()
vim.notify("✅ 灵州站环境修复版：原版插件已全部找回，LSP 已更新为 ts_ls")
