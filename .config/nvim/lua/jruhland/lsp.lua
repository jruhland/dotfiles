vim.lsp.enable({
    'gopls',
    'lua-ls',
    'ts-ls',
    'rust-analyzer',
    'tailwindcss',
})

vim.diagnostic.config({
    virtual_lines = true,
    underline = true,
})

