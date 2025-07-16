vim.lsp.enable({
  "gopls",
  "lua-ls",
  "ts-ls",
  "rust-analyzer",
  "tailwindcss",
})

vim.lsp.config("*", {
  capabilities = {
    textDocument = {
      semanticTokens = {
        multilineTokenSupport = true,
      },
    },
  },
  root_markers = { ".git" },
})

vim.diagnostic.config({
  virtual_lines = true,
  underline = true,
})

vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev)
vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next)
