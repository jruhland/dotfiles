return {
  "stevearc/conform.nvim",
  opts = {},
  config = function()
    local js_formatters = { "oxlint", "oxfmt" }

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
        go = { "gofmt" },
        lua = { "stylua" },
        python = { "ruff" },
        javascript = js_formatters,
        javascriptreact = js_formatters,
        typescript = js_formatters,
        typescriptreact = js_formatters,
        sh = { "shfmt" },
        dockerfile = { "hadolint" },
        bash = { "shfmt" },
        gitcommit = { "commitlint" },
        graphql = { "prettier" },
        sql = { "sqlfluff" },
      },
    })
  end,
}
