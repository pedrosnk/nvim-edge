# Neovim Configuration Guide

This document provides comprehensive guidelines for managing and expanding the pedrosnk Neovim configuration. It covers directory structure, plugin organization with Lazy.nvim, Mason tooling setup, and Lua best practices.

## Directory Structure

```
~/.config/nvim/
├── init.lua                  # Main entry point
├── after/
│   └── plugin/               # Post-loading configurations (sorted by plugin name)
│       ├── keymaps.lua       # Global keymaps
│       ├── telescope.lua     # Telescope keymaps and config
│       ├── lsp.lua           # LSP setup and client configurations
│       ├── nvim_cmp.lua      # Completion plugin setup
│       ├── treesitter.lua    # Treesitter-specific configs
│       └── ...
├── lua/
│   └── pedrosnk/             # Main namespace
│       ├── init.lua          # Main entry point (requires lazy.lua)
│       ├── lazy.lua          # Lazy.nvim bootstrap and config
│       ├── plugins/          # Lazy.nvim plugin specifications (specs only)
│       │   ├── telescope.lua
│       │   ├── nvim_lspconfig.lua
│       │   ├── mason.lua
│       │   ├── treesitter.lua
│       │   └── ...
│       └── ...
└── lazy-lock.json            # Plugin lock file (auto-generated)
```

### Directory Purpose

- **lua/**: All Lua-related configuration files
- **lua/pedrosnk/**: Main namespace containing all project-specific code
- **lua/pedrosnk/init.lua**: Entry point that requires lazy.lua
- **lua/pedrosnk/lazy.lua**: Lazy.nvim bootstrap and configuration
- **lua/pedrosnk/plugins/**: Individual plugin specifications (plugin specs only, no keymaps)
- **after/plugin/**: Post-load configurations executed after all plugins are loaded
  - Keymaps and key bindings (organized by plugin name)
  - Plugin-specific configurations
  - LSP client setup and overrides
  - Any other post-load customizations that depend on plugins being loaded

## Plugin Organization

### Plugin File Naming Conventions

Use snake_case with the plugin name. Example files:

```
plugins/
├── telescope.lua            # telescope.nvim plugin
├── nvim_lspconfig.lua       # nvim-lspconfig plugin
├── nvim_cmp.lua             # nvim-cmp completion plugin
├── treesitter.lua           # nvim-treesitter plugin
├── which_key.lua            # which-key.nvim plugin
├── mason.lua                # mason.nvim plugin
└── mason_lspconfig.lua      # mason-lspconfig.nvim plugin
```

### Plugin Specification Structure

Each plugin file should return a single plugin spec or a table of related plugin specs. Plugin specifications should contain ONLY the plugin definition, dependencies, and lazy-loading conditions. Keymaps and configurations belong in `after/plugin/`:

```lua
-- lua/pedrosnk/plugins/telescope.lua
-- Plugin spec only: installation and lazy loading
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-fzf-native.nvim",
  },
  cmd = "Telescope",
  event = "VeryLazy",
  opts = {
    defaults = {
      file_ignore_patterns = { "node_modules", ".git" },
    },
  },
}
```

```lua
-- after/plugin/telescope.lua
-- Keymaps and configuration for telescope (runs after plugins load)
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })

require("telescope").setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

require("telescope").load_extension("fzf")
```

### Lazy Loading Best Practices

Lazy.nvim supports multiple lazy-loading strategies. Use the most appropriate for each plugin:

#### Command-based Lazy Loading (`cmd`)

Use when plugin is triggered by commands:

```lua
{
  "telescope/telescope.nvim",
  cmd = { "Telescope", "TelescopeBuffers" },
}
```

#### Event-based Lazy Loading (`event`)

Use for plugins that should load on specific events:

```lua
{
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
}
```

Common events:
- `BufReadPre`, `BufNewFile` - file opening
- `FileType` - specific filetypes
- `VeryLazy` - after startup (good for non-critical plugins)

#### Key Mapping-based Lazy Loading (`keys`)

Use when plugin is triggered by keymaps:

```lua
{
  "nvim-tree/nvim-tree.lua",
  keys = {
    { "<C-n>", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
  },
}
```

#### Eager Loading (`lazy = false`)

Use for plugins required at startup (e.g., colorscheme, core utilities):

```lua
{
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,  -- Load before other plugins
}
```

### Dependency Management

Use the `dependencies` field to manage plugin relationships:

```lua
{
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
  },
}
```

Dependencies are:
- Automatically installed with the parent plugin
- Ordered correctly to prevent initialization issues
- Loaded in dependency order during startup

### Merging Parent Specs

When overriding a parent spec (e.g., from LazyVim), these fields are merged:
- `opts`
- `dependencies`
- `cmd`
- `event`
- `ft` (filetypes)
- `keys`

All other properties override the parent spec. Example:

```lua
-- Merging opts with parent spec
{
  "nvim-lspconfig/nvim-lspconfig",
  opts = {
    servers = {
      lua_ls = {
        settings = {
          Lua = { diagnostics = { globals = { "vim" } } },
        },
      },
    },
  },
}
```

## Lazy.nvim Bootstrap

Lazy.nvim bootstrap is separated into two files for better organization:

### Main Entry Point (`lua/pedrosnk/init.lua`)

```lua
-- lua/pedrosnk/init.lua
-- Main entry point - requires lazy configuration
require("pedrosnk.lazy")
```

### Lazy Configuration (`lua/pedrosnk/lazy.lua`)

```lua
-- lua/pedrosnk/lazy.lua
-- Bootstrap and configure Lazy.nvim

-- Bootstrap Lazy.nvim installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit...", "" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup Lazy.nvim with specs and options
require("lazy").setup({
  spec = {
    { import = "pedrosnk.plugins" },
  },
  defaults = {
    lazy = true,
    version = false,  -- Use latest git commits
  },
  install = {
    colorscheme = { "tokyonight" },
  },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

### Main init.lua Structure

The root `init.lua` file should require the pedrosnk module:

```lua
-- ~/.config/nvim/init.lua
require("pedrosnk")
```

## Mason Integration

Mason is a package manager for LSP servers, formatters, and linters. Integration pattern:

```lua
-- lua/pedrosnk/plugins/mason.lua
return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "typescript-language-server",
      },
      automatic_enable = true,
    },
  },
}
```

### Mason Best Practices

1. **Do not lazy-load Mason**: Mason should be available early in startup
2. **Use ensure_installed**: Automatically installs specified tools on startup
3. **Leverage mason-lspconfig**: Bridges Mason installations with lspconfig
4. **Registry updates**: Run `:MasonUpdate` periodically for latest packages
5. **Health checks**: Use `:checkhealth mason` to verify installation

### LSP Configuration Pattern

```lua
-- lua/pedrosnk/plugins/nvim_lspconfig.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason.nvim",
    "mason-lspconfig.nvim",
  },
  config = function()
    local lspconfig = require("lspconfig")
    
    -- Default handler for all servers
    require("mason-lspconfig").setup_handlers({
      function(server_name)
        lspconfig[server_name].setup({})
      end,
      
      -- Custom configurations per server
      lua_ls = function()
        lspconfig.lua_ls.setup({
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              runtime = { version = "LuaJIT" },
            },
          },
        })
      end,
    })
  end,
}
```

## after/plugin Configuration

The `after/plugin/` directory contains configuration that runs after all plugins are loaded. This is ideal for:

### Keymaps (`after/plugin/keymaps.lua`)

```lua
-- Define keybindings after plugins are initialized
local keymap = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.noremap = opts.noremap ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- LSP keymaps
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "Find References" })
keymap("n", "K", vim.lsp.buf.hover, { desc = "Hover" })

-- Telescope keymaps
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files" })
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
```

### Plugin-specific Configuration (`after/plugin/telescope.lua`)

```lua
-- Plugin-specific settings after initialization
require("telescope").setup({
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

require("telescope").load_extension("fzf")
```

### LSP Client Setup (`after/plugin/lsp.lua`)

```lua
-- LSP client setup after plugins are loaded
local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
end

-- Capabilities for completion plugin
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Apply to all servers
require("lspconfig").util.on_setup = function(server)
  server.on_attach = on_attach
  server.capabilities = capabilities
end
```

## Lua Code Conventions

All code follows standard Lua conventions with 2-space indentation:

### Indentation

- Use 2 spaces for indentation (soft tabs, not tabs)
- Do not mix tabs and spaces
- Use Unix (LF) line endings

```lua
-- Good indentation
if condition then
  print("hello")
  for i = 1, 10 do
    print(i)
  end
end
```

### Naming Conventions

- **Variables and functions**: snake_case
- **Constants**: SCREAMING_SNAKE_CASE
- **Private variables/functions**: leading underscore (_private_var)
- **Plugin files**: snake_case matching plugin name

```lua
-- Good naming
local my_variable = 10
local MAX_RETRIES = 3
local _internal_helper = function() end

function my_module.public_function()
  return _internal_helper()
end
```

### Whitespace and Operators

Use spaces around binary operators and after commas:

```lua
-- Good
local x = y * 9 + 3
local numbers = { 1, 2, 3 }
local table = { key = "value", other = 42 }
dog.set("attr", { age = "1 year" })

-- Avoid
local x = y*9+3
local numbers = {1,2,3}
local table = {key="value",other=42}
dog.set( "attr" , { age = "1 year" } )
```

### Comments

- Use spaces after comment markers: `-- comment`
- Start comments with capital letters
- Use TODO/FIXME tags for pending work

```lua
-- Good
-- This function does something important
local function helper()
  -- TODO: improve performance here
  return calculate_value()
end

-- Avoid
--this is a comment
local function helper() --computes value
  return calculate_value() --result
end
```

### Function and Table Definition

```lua
-- Function definition
local function process_data(input, options)
  options = options or {}
  local result = {}
  
  -- Process logic
  return result
end

-- Table definitions
local config = {
  timeout = 5000,
  retries = 3,
  handlers = {
    error = function(err)
      print(err)
    end,
  },
}

-- Trailing commas are acceptable in multi-line tables
local items = {
  "apple",
  "banana",
  "orange",
}
```

## Performance Optimization

### 1. Plugin Lazy Loading

- Default to lazy loading: `lazy = true` in Lazy.nvim defaults
- Use eager loading (`lazy = false`) only for essential plugins
- Prioritize critical plugins (colorscheme, core utilities)

### 2. Selective Plugin Installation

```lua
-- Use `enabled` to conditionally include plugins
{
  "nvim-tree/nvim-tree.lua",
  enabled = vim.fn.executable("fd") == 1,
  cmd = "NvimTreeToggle",
}
```

### 3. Defer Non-Essential Plugins

```lua
{
  "my-plugin/plugin.lua",
  event = "VeryLazy",  -- Load after startup
}
```

### 4. Profile Startup

Use `:Lazy profile` to identify slow-loading plugins and optimize:
- Check for plugins loading synchronously
- Move to lazy loading where possible
- Review plugin configurations for performance

### 5. Disable Unnecessary Built-in Plugins

Configure in Lazy.nvim performance section:

```lua
performance = {
  rtp = {
    disabled_plugins = {
      "gzip",
      "tarPlugin",
      "tohtml",
      "tutor",
      "zipPlugin",
    },
  },
}
```

## Common Patterns and Examples

### Adding a New Plugin

1. Create `lua/pedrosnk/plugins/plugin_name.lua` with plugin spec (no keymaps)
2. Create `after/plugin/plugin_name.lua` for keymaps and configuration
3. Plugin specs should contain: source, dependencies, lazy loading conditions, and options
4. Post-load files should contain: keymaps, setup calls, and configurations

**Plugin Specification** (`lua/pedrosnk/plugins/example_plugin.lua`):

```lua
return {
  "author/example-plugin",
  event = "BufReadPre",
  dependencies = {
    "other-plugin/dependency",
  },
  opts = {
    setting = true,
    nested = {
      value = 10,
    },
  },
}
```

**Keymaps and Configuration** (`after/plugin/example_plugin.lua`):

```lua
-- Keymaps for example-plugin
vim.keymap.set("n", "<leader>ex", "<cmd>ExampleCommand<cr>", {
  desc = "Example command",
})

-- Additional configuration
require("example_plugin").setup({
  hooks = {
    on_complete = function()
      print("Complete!")
    end,
  },
})
```

### Overriding Parent Plugin Configuration

```lua
-- lua/pedrosnk/plugins/overrides.lua
return {
  -- Override telescope from parent
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults.file_ignore_patterns =
        vim.list_extend(opts.defaults.file_ignore_patterns or {}, {
          "vendor/",
          "node_modules/",
        })
      return opts
    end,
  },
}
```

### Conditional Plugin Loading

```lua
-- lua/pedrosnk/plugins/conditional.lua
return {
  {
    "language-specific/plugin",
    ft = { "rust", "go" },  -- Load for specific filetypes
  },
  {
    "dev-only/plugin",
    enabled = os.getenv("NVIM_DEV") == "1",  -- Load based on env
  },
}
```

## Command-Line Testing and Validation

### Syntax Validation

Verify your configuration doesn't have Lua syntax errors:

```bash
# Check init.lua for syntax errors
nvim --cmd 'set nomore' -c 'try | source ~/.config/nvim/init.lua | catch | messages | quit | endtry | quit'

# More comprehensive check using Neovim's built-in luacheck (if available)
luacheck ~/.config/nvim/lua/

# Alternative: run Neovim in headless mode and check for errors
nvim --headless -c 'redir! > /tmp/nvim_errors.log | silent messages | redir END | quit'
cat /tmp/nvim_errors.log
```

### Startup Time Profiling

Measure startup performance and identify slow plugins:

```bash
# Measure startup time and save report
nvim --startuptime startup.log -c 'quit'
cat startup.log

# Show top slow files (sorted by time)
tail -30 startup.log | sort -k2 -rn

# Profile within Lazy.nvim
nvim -c 'Lazy profile | quit'
```

### Plugin Installation Verification

Verify plugins are correctly installed:

```bash
# Open Lazy.nvim UI and check status
nvim -c 'Lazy'

# Headless check for installed plugins
nvim --headless '+Lazy! sync' '+quit'

# List all loaded plugins
nvim --headless -c 'Lazy show' -c 'quit'

# Check specific plugin
nvim --headless -c 'Lazy show telescope.nvim' -c 'quit'
```

### Mason Tool Installation Verification

Verify LSP servers and tools are correctly installed:

```bash
# Check Mason health
nvim +checkhealth\ mason -c 'quit'

# Comprehensive health check
nvim +checkhealth -c 'quit'

# List installed Mason tools (headless)
nvim --headless -c 'MasonInstall' -c 'quit'

# Verify specific LSP is installed
nvim --headless -c "lua require('lspconfig').lua_ls.setup({})" -c 'quit'
```

### Configuration Load Testing

Test that your configuration loads without errors:

```bash
# Start Neovim and immediately check for errors
nvim --headless -c 'redir! > /tmp/config_check.log | silent messages | redir END | quit'
cat /tmp/config_check.log

# Test file loading with verbose mode
nvim --noplugin -u ~/.config/nvim/init.lua -c 'quit' 2>&1 | tee /tmp/nvim_verbose.log

# Check for any Lua errors in logs
grep -i 'error\|fail\|exception' /tmp/nvim_verbose.log
```

### LSP Configuration Testing

Verify LSP servers attach correctly:

```bash
# Check LSP info in a buffer
nvim +LSP\ info +quit

# Test specific filetype LSP loading (create test file and check)
nvim -c 'edit test.lua | LSP info | quit'

# Headless LSP check
nvim --headless -c 'lua require("lspconfig").lua_ls.setup({})' -c 'lua print(vim.inspect(vim.lsp.get_clients()))' -c 'quit'
```

### Automated Testing Script

Create a validation script to test everything:

```bash
#!/bin/bash
# ~/.config/nvim/validate.sh

set -e

echo "=== Neovim Configuration Validation ==="
echo ""

# Check syntax
echo "1. Checking Lua syntax..."
if nvim --noplugin -u ~/.config/nvim/init.lua -c 'quit' 2>&1 | grep -q 'Error'; then
  echo "❌ Syntax error found"
  exit 1
else
  echo "✓ Syntax check passed"
fi

# Check startup time
echo ""
echo "2. Checking startup time..."
nvim --startuptime /tmp/startup.log -c 'quit' > /dev/null 2>&1
startup_time=$(tail -1 /tmp/startup.log | awk '{print $1}')
echo "✓ Startup time: ${startup_time}ms"

# Check plugins load
echo ""
echo "3. Checking plugin loading..."
if nvim --headless -c 'Lazy check' -c 'quit' 2>&1 | grep -q 'error'; then
  echo "❌ Plugin loading error"
  exit 1
else
  echo "✓ Plugins loaded successfully"
fi

# Check Mason health
echo ""
echo "4. Checking Mason installation..."
nvim --headless +checkhealth\ mason -c 'quit' > /tmp/mason_health.log 2>&1
if grep -q 'ERROR' /tmp/mason_health.log; then
  echo "❌ Mason health check failed"
  cat /tmp/mason_health.log
else
  echo "✓ Mason health check passed"
fi

# Check LSP servers
echo ""
echo "5. Checking LSP servers..."
nvim --headless -c 'lua print("LSP check passed")' -c 'quit' > /dev/null 2>&1
echo "✓ LSP configuration OK"

echo ""
echo "=== All validation checks passed! ==="
```

Make it executable and run:

```bash
chmod +x ~/.config/nvim/validate.sh
~/.config/nvim/validate.sh
```

### Common Validation Commands Reference

| Task | Command |
|------|---------|
| Check all errors | `nvim --headless -c 'redir! > /tmp/errors.log \| silent messages \| redir END \| quit' && cat /tmp/errors.log` |
| Profile startup | `nvim --startuptime startup.log -c 'quit' && tail -20 startup.log` |
| Check plugins | `nvim --headless -c 'Lazy check' -c 'quit'` |
| Check health | `nvim +checkhealth -c 'quit'` |
| List LSP servers | `nvim --headless -c 'LspInfo' -c 'quit'` |
| Verify Mason | `nvim --headless +checkhealth\ mason -c 'quit'` |
| Open lazy UI | `nvim -c 'Lazy'` |
| Quick syntax test | `nvim --noplugin -u ~/.config/nvim/init.lua -c 'quit'` |

### In-Editor Commands Reference

Run these commands inside Neovim for interactive debugging:

| Command | Purpose |
|---------|---------|
| `:Lazy` | Open Lazy.nvim UI (check plugin status) |
| `:Lazy show <plugin>` | Inspect specific plugin details |
| `:Lazy profile` | Profile plugin startup times |
| `:Lazy update` | Update all plugins |
| `:Lazy sync` | Sync plugins with lock file |
| `:Lazy clean` | Remove unused plugins |
| `:Lazy log` | Show Lazy.nvim log messages |
| `:LspInfo` | Show attached LSP servers for current buffer |
| `:Mason` | Open Mason UI for tool management |
| `:MasonInstall <tool>` | Install specific tool |
| `:MasonUpdate` | Update Mason registry |
| `:checkhealth` | Run all health checks |
| `:checkhealth mason` | Check Mason-specific health |
| `:checkhealth lsp` | Check LSP health |
| `:TSInstall <lang>` | Install Treesitter parser for language |
| `:messages` | Show all messages since startup |

### Debugging Workflow

When something breaks, follow this systematic approach:

1. **Check syntax errors**:
   ```bash
   nvim --noplugin -u ~/.config/nvim/init.lua -c 'quit' 2>&1
   ```

2. **View startup errors**:
   ```bash
   nvim --headless -c 'redir! > /tmp/errors.log | silent messages | redir END | quit'
   cat /tmp/errors.log
   ```

3. **Check plugin loading**:
   ```bash
   nvim -c 'Lazy'  # Interactive UI to see which plugins failed
   ```

4. **Check LSP attachment**:
   ```bash
   nvim test.lua -c 'LspInfo'  # Create a test file and check
   ```

5. **Profile startup**:
   ```bash
   nvim --startuptime startup.log -c 'quit'
   tail -30 startup.log
   ```

6. **Check Mason tools**:
   ```bash
   nvim -c 'Mason'  # UI to see tool installation status
   ```

7. **Look for specific errors**:
   - Open the Lazy UI with `:Lazy` and look for red X marks
   - Check `:messages` for error output
   - Review `/tmp/errors.log` for detailed error traces

## Best Practices Summary

1. **Plugin specs only in plugins/**: Keep `lua/pedrosnk/plugins/` files focused only on plugin installation and lazy-loading
2. **Keymaps in after/plugin/**: All keybindings and post-load configs belong in `after/plugin/` organized by plugin name
3. **One plugin per file**: Keep plugin specs modular in individual files
4. **Lazy load by default**: Only eager-load truly essential plugins (colorschemes, core utilities)
5. **Use dependencies**: Declare plugin relationships explicitly to ensure proper ordering
6. **Separate concerns**: Plugin specs handle installation, after/plugin handles functionality
7. **Snake case everything**: Plugin files, functions, variables follow snake_case
8. **2-space indentation**: Maintain consistent Lua code style throughout
9. **Test before committing**: Run validation scripts to catch breakage early
10. **Use command-line tools**: Leverage `--startuptime`, `--headless`, and health checks
11. **Monitor startup time**: Keep startup under 100ms with proper lazy loading
12. **Keep keymaps centralized**: Group related keymaps in `after/plugin/` by plugin

## Resources

- [Lazy.nvim Documentation](https://github.com/folke/lazy.nvim)
- [Mason.nvim Documentation](https://github.com/mason-org/mason.nvim)
- [Lua Style Guide](https://github.com/luarocks/lua-style-guide)
- [Neovim LSP Documentation](https://neovim.io/doc/user/lsp.html)
