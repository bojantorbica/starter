return {
  -- mason.nvim
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
      ensure_installed = {
        "html",
        "cssls",
        "ada_ls",
        "ts_ls",
        "clangd",
        "elixirls",
        "gopls",
        "hls",
        "cmake",
        "lua_ls",
        "glsl_analyzer",
        "zls",
      },
    },
  },

  -- conform.nvim
  {
    "stevearc/conform.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "BufWritePre", -- uncomment for format on save
    init = function()
      vim.keymap.set("n", "<leader>fm", function()
        require("conform").format { lsp_fallback = true }
      end, { desc = "General format file" })
    end,
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        go = { "gofmumpt" },
        html = { "prettier" },
        javascript = { "prettier" },
        json = { "biome" },
        markdown = { "markdownlint" },
        python = { "ruff_format" },
        typescript = { "prettier" },
        lua = { "stylua" },
        yaml = { "yamlfmt" },
        zig = { "zigfmt" },
        haskell = { "ormolu" },
      },
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 5000, lsp_fallback = true }
      end,
      formatters = {
        yamlfmt = {
          args = { "-formatter", "retain_line_breaks_single=true" },
        },
      },
    },
  },

  -- nvim-lspconfig.nvim
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- nvim-treesitter.nvim
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "c",
        "cpp",
        "go",
        "cuda",
        "bibtex",
        "asm",
        "ada",
        "cmake",
        "dockerfile",
        "elixir",
        "erlang",
        "gitignore",
        "gitcommit",
        "gomod",
        "gosum",
        "hlsl",
        "json",
        "latex",
        "matlab",
        "ninja",
        "powershell",
        "sql",
        "typescript",
        "javascript",
        "xml",
        "zig",
        "yaml",
        "python",
        "haskell",
      },
      auto_install = true,
      indent = { enable = true },
      highlight = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>is",
          node_incremental = "<Tab>",
          scope_incremental = "<S-s>",
          node_decremental = "<S-Tab>",
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select around function" },
            ["if"] = { query = "@function.inner", desc = "Select inner part of function" },
            ["ac"] = { query = "@class.outer", desc = "Select around class" },
            ["ic"] = { query = "@class.inner", desc = "Select inner part of class" },
            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
          },
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "<c-v>",
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>wn"] = "@parameter.inner",
          },
          swap_previous = {
            ["<leader>wp"] = "@parameter.inner",
          },
        },
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
  },

  -- indent-blankline.nvim
  {
    "lukas-reineke/indent-blankline.nvim",
  },

  -- cmp.nvim
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      { "hrsh7th/cmp-cmdline" },
      { "brenoprata10/nvim-highlight-colors" },
    },
    config = function(_, opts)
      local cmp = require "cmp"

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "cmdline" },
          { name = "path" },
          {
            name = "lazydev",
            group_index = 0, -- set group index to 0 to skip loading LuaLS completions
          },
        },
      })

      local colors = require "nvim-highlight-colors.color.utils"
      local utils = require "nvim-highlight-colors.utils"

      ---@class cmp.FormattingConfig
      --- This makes chadrc.ui.cmp take no effect
      opts.formatting = {
        fields = { "abbr", "kind", "menu" },

        format = function(entry, item)
          local icons = require "nvchad.icons.lspkind"
          icons.Color = "󱓻"

          local icon = " " .. icons[item.kind] .. " "
          item.kind = string.format("%s%s ", icon, item.kind)

          local entryItem = entry:get_completion_item()
          if entryItem == nil then
            return item
          end

          local entryDoc = entryItem.documentation
          if entryDoc == nil or type(entryDoc) ~= "string" then
            return item
          end

          local color_hex = colors.get_color_value(entryDoc)
          if color_hex == nil then
            return item
          end

          local highlight_group = utils.create_highlight_name("fg-" .. color_hex)
          vim.api.nvim_set_hl(0, highlight_group, { fg = color_hex, default = true })
          item.kind_hl_group = highlight_group

          return item
        end,
      }

      ---@type cmp.ConfigSchema
      local custom_opts = {
        window = {
          completion = {
            border = "rounded",
          },
          documentation = {
            border = "rounded",
          },
        },
      }

      opts = vim.tbl_deep_extend("force", opts, custom_opts)
      cmp.setup(opts)
    end,
  },

  -- autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- dap-ui
  {
    "rcarriga/nvim-dap-ui",
    event = "LspAttach",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {},
    config = function()
      local map = vim.keymap.set
      local dap = require "dap"
      local dapui = require "dapui"
      local widgets = require "dap.ui.widgets"
      local sidebar = widgets.sidebar(widgets.scopes)

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      map("n", "<leader>db", "<cmd>DapToggleBreakpoint<CR>", { desc = "DAP Toggle breakpoint" })
      map("n", "<leader>dt", function()
        sidebar.toggle()
      end, { desc = "DAP Toggle sidebar" })
    end,
  },

  -- nvim-dap-virtual-text
  {
    "theHamsta/nvim-dap-virtual-text",
    event = "LspAttach",
    config = function(_, opts)
      require("nvim-dap-virtual-text").setup()
    end,
  },

  -- dressing
  {
    -- enabled = false,
    "stevearc/dressing.nvim",
    event = "UIEnter",
  },

  -- dropbar
  {
    "Bekaboo/dropbar.nvim",
    lazy = false,
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
  },

  -- gitsigns
  {
    "lewis6991/gitsigns.nvim",
    dependencies = "sindrets/diffview.nvim",
    ---@class Gitsigns.Config
    opts = {
      preview_config = {
        border = "rounded",
      },
      on_attach = function(bufnr)
        local gs = require "gitsigns"
        local map = require("utils.utils").buf_map

        map(bufnr, "n", "<leader>td", gs.toggle_deleted, { desc = "Gitsigns toggle deleted" })
        map(bufnr, "n", "<leader>hr", gs.reset_hunk, { desc = "Gitsigns reset hunk" })
        map(bufnr, "n", "<leader>hs", gs.stage_hunk, { desc = "Gitsigns stage hunk" })
        map(bufnr, "n", "<leader>hu", gs.undo_stage_hunk, { desc = "Gitsigns undo stage hunk" })
        map(bufnr, "n", "<leader>hS", gs.stage_buffer, { desc = "Gitsigns stage buffer" })
        map(bufnr, "n", "<leader>hR", gs.reset_buffer, { desc = "Gitsigns reset buffer" })
        map(bufnr, "n", "<leader>hh", gs.preview_hunk, { desc = "Gitsigns preview hunk" })
        map(bufnr, { "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Gitsigns select hunk" })

        map(bufnr, "n", "<leader>hn", function()
          if vim.wo.diff then
            vim.cmd.normal { "<leader>hn", bang = true }
          else
            gs.nav_hunk "next"
          end
        end, { desc = "Gitsigns next hunk" })

        map(bufnr, "n", "<leader>hb", function()
          if vim.wo.diff then
            vim.cmd.normal { "<leader>hp", bang = true }
          else
            gs.nav_hunk "prev"
          end
        end, { desc = "Gitsigns previous hunk" })

        map(bufnr, "n", "<leader>bl", function()
          gs.blame_line { full = true }
        end, { desc = "Gitsigns blame line" })
      end,
    },
  },

  -- helpview
  {
    "OXY2DEV/helpview.nvim",
    lazy = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },

  -- hop
  {
    "smoka7/hop.nvim",
    cmd = { "HopWord", "HopLine", "HopLineStart", "HopWordCurrentLine" },
    init = function()
      local map = vim.keymap.set
      map("n", "<leader><leader>w", "<cmd>HopWord<CR>", { desc = "Hint all words" })
      map("n", "<leader><leader>t", "<cmd>HopNodes<CR>", { desc = "Hint Tree" })
      map("n", "<leader><leader>c", "<cmd>HopLineStart<CR>", { desc = "Hint Columns" })
      map("n", "<leader><leader>l", "<cmd>HopWordCurrentLine<CR>", { desc = "Hint Line" })
    end,
    opts = { keys = "etovxqpdygfblzhckisuran" },
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "hop")
      require("hop").setup(opts)
    end,
  },

  -- nvim-lsp-endhints
  {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    opts = {},
  },

  -- vim-matchup
  {
    "andymass/vim-matchup",
    event = "LspAttach",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- neogit
  {
    "NeogitOrg/neogit",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    init = function()
      local map = vim.keymap.set
      map("n", "<leader>gg", "<cmd>Neogit<CR>", { desc = "Neogit Open" })
    end,
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "neogit")
      require("neogit").setup(opts)

      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd
      autocmd("BufEnter", {
        desc = "Disable statuscol in Neogit* buffers.",
        pattern = "NeogitStatus",
        group = augroup("DisableStatuscol", { clear = true }),
        callback = function()
          vim.schedule(function()
            vim.o.statuscolumn = "%!v:lua.require('statuscol').get_statuscol_string()"
          end)
        end,
      })
    end,
  },

  -- noice
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      cmdline = {
        enabled = false,
      },
      messages = {
        enabled = false,
      },
      popupmenu = {
        enabled = false,
      },
      notify = {
        enabled = false,
      },
      lsp = {
        hover = {
          enabled = true,
          opts = {
            border = "rounded",
          },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        signature = {
          enabled = true,
          opts = {
            border = "rounded",
          },
        },
        progress = {
          enabled = false,
        },
        message = {
          enabled = false,
        },
      },
    },
  },

  -- nvim-notify
  {
    "rcarriga/nvim-notify",
    lazy = false,
    config = function()
      dofile(vim.g.base46_cache .. "notify")

      vim.notify = require "notify"
      ---@diagnostic disable-next-line
      vim.notify.setup {
        background_colour = "#1c2433",
        top_down = true,
      }
    end,
  },

  -- outline
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    init = function()
      vim.keymap.set("n", "<leader>oo", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
    end,
    config = function()
      require("outline").setup {}
    end,
  },

  -- nvim-regexplainer
  {
    "bennypowers/nvim-regexplainer",
    event = "BufEnter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("regexplainer").setup()
    end,
  },

  -- statuscol
  {
    "luukvbaal/statuscol.nvim",
    lazy = false,
    config = function()
      local builtin = require "statuscol.builtin"

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        group = vim.api.nvim_create_augroup("SmarterFoldColumn", { clear = true }),
        callback = function(event)
          if vim.bo[event.buf].buftype == "help" then
            vim.opt_local.foldcolumn = "0"
          end
        end,
      })

      require("statuscol").setup {
        bt_ignore = { "terminal", "help", "nofile" },
        ft_ignore = { "oil" },
        relculright = true,
        segments = {
          { text = { "%s" }, foldclosed = true, click = "v:lua.ScSa" },
          {
            text = { builtin.foldfunc, "  " },
            condition = { builtin.not_empty, true, builtin.not_empty },
            foldclosed = true,
            click = "v:lua.ScFa",
          },
          { text = { builtin.lnumfunc, " " }, foldclosed = true, click = "v:lua.ScLa" },
        },
      }
    end,
  },

  -- tiny-code-action
  {
    "rachartier/tiny-code-action.nvim",
    event = "LspAttach",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      local map = require("utils.utils").glb_map

      map({ "n", "v" }, "<leader>ca", function()
        require("tiny-code-action").code_action()
      end, { desc = "Tiny code action" })

      require("tiny-code-action").setup()
    end,
  },

  -- tiny-inline-diagnostic
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    config = function()
      require("tiny-inline-diagnostic").setup()
    end,
  },

  -- nvim-treesitter-textobjects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },

  -- trouble
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>tt",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>tb",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>to",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>tL",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>tl",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>tq",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },

  -- vim-illuminate
  {
    "RRethy/vim-illuminate",
    enabled = false,
    event = "BufEnter",
    opts = {
      filetypes_denylist = { "NvimTree", "TelescopePrompt", "NeogitStatus", "lazy", "mason" },
    },
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "vim-illuminate")
      require("illuminate").configure(opts)
    end,
  },

  -- binary-peek
  {
    "mgastonportillo/binary-peek.nvim",
    enabled = false,
    dev = true,
    name = "binary-peek",
    event = "VeryLazy",
    init = function()
      local map = vim.keymap.set
      map("n", "<leader>bs", "<cmd>BinaryPeek<CR>", { desc = "BinaryPeek start" })
      map("n", "<leader>bx", "<cmd>BinaryPeek abort<CR>", { desc = "BinaryPeek abort" })
    end,
    config = true,
  },
}
