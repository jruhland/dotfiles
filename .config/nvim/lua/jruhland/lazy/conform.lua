return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    require("conform").setup({
      quiet = true,
      notify_no_formatters = false,
      format_on_save = {
        enabled = true,
        timeout = 100,
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        -- go = { "gofmt" },
        lua = { "stylua" },
        -- rust = { "rustfmt" },
        -- python = { "isort", "black" },
        javascript = { "biome", stop_after_first = true },
        javascriptreact = { "biome", stop_after_first = true },
        typescript = { "biome", stop_after_first = true },
        typescriptreact = { "biome", stop_after_first = true },
        json = { "biome", stop_after_first = true },
        css = { "biome", stop_after_first = true },
      },
    })
  end,
}
