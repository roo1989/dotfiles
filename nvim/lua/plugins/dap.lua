return {
  { "mfussenegger/nvim-dap" },

  -- REQUIRED by nvim-dap-ui
  { "nvim-neotest/nvim-nio" },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- --- FIX: make dapui open/close resilient + avoid duplicate opens ---
      local ui_open = false

      local function safe_open()
        if ui_open then return end
        ui_open = true
        -- schedule + pcall prevents "Invalid buffer id: -1" from blowing up the session
        vim.schedule(function()
          pcall(dapui.open)
        end)
      end

      local function safe_close()
        if not ui_open then return end
        ui_open = false
        vim.schedule(function()
          pcall(dapui.close)
        end)
      end

      dap.listeners.after.event_initialized["dapui_config"] = function()
        safe_open()
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        safe_close()
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        safe_close()
      end

      -- Keymaps
      local map = vim.keymap.set
      map("n", "<F5>", dap.continue, { desc = "DAP Continue" })
      map("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
      map("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
      map("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
      map("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "DAP Conditional Breakpoint" })
      map("n", "<leader>dr", dap.repl.open, { desc = "DAP REPL" })

      -- Make toggle also keep our state in sync
      map("n", "<leader>du", function()
        if ui_open then
          safe_close()
        else
          safe_open()
        end
      end, { desc = "DAP UI Toggle" })
    end,
  },

  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap_python = require("dap-python")

      -- --- Python interpreter: prefer project .venv (uv) ---
      local function find_project_root()
        local ok, util = pcall(require, "lspconfig.util")
        if not ok then
          return vim.fn.getcwd()
        end
        local root = util.root_pattern("pyproject.toml", "manage.py", ".git")(vim.fn.getcwd())
        return root or vim.fn.getcwd()
      end

      local function python_path()
        local root = find_project_root()
        local venv_python = root .. "/.venv/bin/python"
        if vim.fn.executable(venv_python) == 1 then
          return venv_python
        end
        local py3 = vim.fn.exepath("python3")
        return py3 ~= "" and py3 or "python"
      end

      dap_python.setup(python_path())

      -- --- Per-project Django defaults via .nvim.lua ---
      local function django_host()
        return vim.g.django_host or "127.0.0.1"
      end

      local function django_port()
        return vim.g.django_port or "8000"
      end

      local function django_settings()
        return vim.g.django_settings -- may be nil
      end

      local dap = require("dap")
      dap.configurations.python = dap.configurations.python or {}

      -- Load KEY=VALUE lines from a .env file into a table
      local function load_dotenv(path)
        local env = {}
        local f = io.open(path, "r")
        if not f then
          return env
        end
        for line in f:lines() do
          if not line:match("^%s*#") and not line:match("^%s*$") then
            local key, value = line:match("^%s*([%w_%.%-]+)%s*=%s*(.-)%s*$")
            if key and value then
              value = value:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
              env[key] = value
            end
          end
        end
        f:close()
        return env
      end

      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Django: runserver (.env + debug)",
        program = function()
          local root = find_project_root()
          if vim.fn.filereadable(root .. "/src/manage.py") == 1 then
            return root .. "/src/manage.py"
          end
          if vim.fn.filereadable(root .. "/manage.py") == 1 then
            return root .. "/manage.py"
          end
          return root .. "/src/manage.py"
        end,
        args = function()
          return { "runserver", django_host() .. ":" .. django_port() }
        end,
        django = true,
        justMyCode = false,
        console = "integratedTerminal",
        env = function()
          local root = find_project_root()
          local env_file = vim.g.django_env_file or ".env"
          if not env_file:match("^/") then
            env_file = root .. "/" .. env_file
          end
          local env = load_dotenv(env_file)
          local settings = django_settings()
          if settings and settings ~= "" then
            env.DJANGO_SETTINGS_MODULE = settings
          end
          env.DEBUG = env.DEBUG or "1"
          env.DJANGO_DEBUG = env.DJANGO_DEBUG or "1"
          env.PYTHONUNBUFFERED = env.PYTHONUNBUFFERED or "1"
          return env
        end,
      })

      table.insert(dap.configurations.python, {
        type = "python",
        request = "attach",
        name = "Python: attach (debugpy)",
        connect = function()
          local host = vim.fn.input("Host: ", "127.0.0.1")
          local port = tonumber(vim.fn.input("Port: ", "5678"))
          return { host = host, port = port }
        end,
        justMyCode = false,
      })
    end,
  },
}
