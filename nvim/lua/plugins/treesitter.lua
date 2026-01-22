return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua", "python", "json", "yaml", "toml", "bash",
        "html", "css", "javascript", "typescript",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Django/templating filetype support
  {
    "leafOfTree/vim-svelte-plugin", -- harmless if unused; optional
    enabled = false,
  },
}
