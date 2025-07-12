vim.lsp.enable({
    'gopls',
    'pyright',
    'ruby-lsp',
    'ts-ls',
    'tailwindcss',
    'rust_analyzer',
    'graphql-language-service-cli',
    'terraform-ls',
    'biome',
})

vim.diagnostic.config({
    virtual_text = true,
    underline = true,
})

