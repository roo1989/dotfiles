return {
  -- Mason (manages external tools)
  {
    "williamboman/mason.nvim",
    config = true,
  },

  -- Mason-LSPConfig (installs LSP servers)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "pyright",
        "ruff",
        "lua_ls",
      },
      automatic_installation = true,
    },
  },

  -- LSP Config (core wiring)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Root detection (prefer Django/pyproject roots)
      local util_ok, util = pcall(require, "lspconfig.util")
      if not util_ok then
        vim.notify("lspconfig.util not found", vim.log.levels.ERROR)
        return
      end

      local root_pattern = util.root_pattern("pyproject.toml", "manage.py", ".git")

      -- Detect .venv/bin/python for uv projects
      local function get_python_path(root_dir)
        local venv_python = root_dir .. "/.venv/bin/python"
        if vim.fn.executable(venv_python) == 1 then
          return venv_python
        end

        local py3 = vim.fn.exepath("python3")
        if py3 ~= "" then
          return py3
        end

        return "python"
      end

      -- Keymaps when an LSP attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local opts = function(desc)
            return { buffer = ev.buf, silent = true, desc = desc }
          end

          local map = vim.keymap.set
          map("n", "K", vim.lsp.buf.hover, opts("Hover"))
          map("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
          map("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
          map("n", "gr", vim.lsp.buf.references, opts("References"))
          map("n", "gi", vim.lsp.buf.implementation, opts("Implementation"))
          map("n", "<leader>rn", vim.lsp.buf.rename, opts("Rename"))
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts("Code action"))
          map("n", "<leader>df", vim.diagnostic.open_float, opts("Diagnostics float"))
          map("n", "[d", vim.diagnostic.goto_prev, opts("Prev diagnostic"))
          map("n", "]d", vim.diagnostic.goto_next, opts("Next diagnostic"))
        end,
      })

      -- Diagnostic UI
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
        signs = true,
        underline = true,
        update_in_insert = false,
      })

      -- Wrapper: Neovim 0.11+ uses vim.lsp.config / vim.lsp.enable
      -- Neovim 0.10 uses lspconfig.<server>.setup(...)
      local function setup(server, opts)
        opts = opts or {}
        opts.capabilities = opts.capabilities or capabilities

        if vim.lsp and vim.lsp.config and vim.lsp.enable then
          -- 0.11+
          vim.lsp.config(server, opts)
          vim.lsp.enable(server)
        else
          -- 0.10 and earlier
          local lspconfig = require("lspconfig")
          lspconfig[server].setup(opts)
        end
      end

      -- -------------------------
      -- Lua LSP (Neovim config)
      -- -------------------------
      setup("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- -------------------------
      -- Ruff LSP (linting, quick fixes)
      -- -------------------------
      setup("ruff", {
        root_dir = root_pattern,
        init_options = {
          settings = {
            -- You can tweak these later
            -- logLevel = "debug",
          },
        },
      })

      -- -------------------------
      -- Pyright (types, intellisense)
      -- -------------------------
      setup("pyright", {
        root_dir = root_pattern,

        before_init = function(_, config)
          config.settings = config.settings or {}
          config.settings.python = config.settings.python or {}
          config.settings.python.pythonPath = get_python_path(config.root_dir)
        end,

        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
              typeCheckingMode = "basic",
            },
          },
        },
      })
    end,
  },
}
