-- Required to properly use system clipboard using WSL
if vim.fn.has('win32') == 0 and os.getenv("WSL_DISTRO_NAME") then
    vim.g.clipboard = {
        name = 'windows-clipboard',
        copy = {
            ['*'] = 'clip.exe',
            ['+'] = 'clip.exe',
        },
        paste = {
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 1,
    }
end
