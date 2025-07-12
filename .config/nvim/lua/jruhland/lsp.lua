vim.lsp.enable({
    'gopls',
    'pyright',
    'ruby-lsp',
    'typescript-language-server',
    'rust_analyzer',
    'graphql-language-service-cli',
    'terraform-ls',
    'biome',
})

vim.diagnostic.config({
    virtual_text = true,
})

