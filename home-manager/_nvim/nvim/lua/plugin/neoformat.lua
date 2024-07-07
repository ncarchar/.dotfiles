vim.g.neoformat_try_formatprg = 1
vim.g.neoformat_basic_format_align = 1
vim.g.neoformat_basic_format_retab = 1
vim.g.neoformat_basic_format_trim = 1

vim.g.neoformat_enabled_javascript = { 'prettier' }
vim.g.neoformat_enabled_typescript = { 'prettier' }
vim.g.neoformat_enabled_html = { 'prettier' }
vim.g.neoformat_enabled_css = { 'prettier' }
vim.g.neoformat_enabled_scss = { 'prettier' }
vim.g.neoformat_enabled_json = { 'prettier' }
vim.g.neoformat_enabled_xml = { 'prettier' }
vim.g.neoformat_enabled_markdown = { 'prettier' }

-- Disable Neoformat for Java
vim.g.neoformat_enabled_java = {}

local function lsp_formatter_available()
    local clients = vim.lsp.get_active_clients()
    for _, client in ipairs(clients) do
        if client.supports_method('textDocument/formatting') then
            return true
        end
    end
    return false
end

local function format_buffer()
    local filetype = vim.bo.filetype
    local formatters = {
        javascript = 'prettier',
        typescript = 'prettier',
        html = 'prettier',
        css = 'prettier',
        scss = 'prettier',
        json = 'prettier',
        yaml = 'prettier',
        markdown = 'prettier',
        nix = 'prettier'
    }

    if formatters[filetype] then
        vim.cmd('Neoformat')
    elseif lsp_formatter_available() then
        vim.lsp.buf.format()
    else
        print('No formatter available for ' .. filetype)
    end
end

-- Set the keymapping
vim.keymap.set('n', '<leader>fl', format_buffer, { noremap = true, desc = 'Format buffer' })
