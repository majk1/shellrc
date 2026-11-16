local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- nvim-lspconfig needs Nvim 0.11.3+; on older Nvim (e.g. apt on Linux) the LSP/completion part is skipped
local has_lsp = vim.fn.has("nvim-0.11.3") == 1

require("lazy").setup({
  {
    "bluz71/vim-nightfly-colors",
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme nightfly]])
    end,
  },
	{
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
	{
		"ibhagwan/fzf-lua",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
		-- calling `setup` is optional for customization
			-- require("fzf-lua").setup({})
			require("fzf-lua")
		end
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = false,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
			})
		end
	},
  {
    "saghen/blink.cmp",
    cond = has_lsp,
    version = "1.*", -- prebuilt fuzzy matcher binary, no Rust toolchain needed
    opts = {
      keymap = { preset = "default" }, -- <C-y> accept, <C-n>/<C-p> select, <C-space> open
      completion = { documentation = { auto_show = true } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            -- several servers can answer for the same file (compose: yamlls + docker_language_server);
            -- a label offered by one client is dropped from the others, so keys are not listed twice
            transform_items = function(_, items)
              local owner = {}
              return vim.tbl_filter(function(item)
                if owner[item.label] == nil then
                  owner[item.label] = item.client_id
                end
                return owner[item.label] == item.client_id
              end, items)
            end,
          },
        },
      },
      fuzzy = { implementation = "prefer_rust" }, -- silently falls back to Lua where no binary exists
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    cond = has_lsp,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig", -- server configs (dockerls, docker_language_server, systemd_lsp)
      "saghen/blink.cmp",
    },
    opts = function()
      local servers = { "docker_language_server" }
      -- dockerls and yamlls are installed with npm; skip them where there is no node, so Mason does not error
      if vim.fn.executable("npm") == 1 then
        table.insert(servers, "dockerls")
        -- yamlls: all YAML files, schemas from SchemaStore; unlike docker_language_server it also
        -- completes compose keys while the YAML is still half-typed (invalid)
        table.insert(servers, "yamlls")
      end
      return { ensure_installed = servers } -- automatic_enable (v2 default) also enables them
    end,
    config = function(_, opts)
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      -- Dockerfiles are handled by dockerls, so no duplicate diagnostics
      vim.lsp.config("docker_language_server", { filetypes = { "yaml.docker-compose", "hcl.docker-bake" } })
      require("mason-lspconfig").setup(opts)
      -- installed with cargo (Mason's macOS arm64 binary is x86_64) or Mason; no error when missing
      if vim.fn.executable("systemd-lsp") == 1 then
        vim.lsp.enable("systemd_lsp")
      end
    end,
  },
})

