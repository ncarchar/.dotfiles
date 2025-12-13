-- Required to properly use system clipboard using WSL
if vim.fn.has("win32") == 0 and os.getenv("WSL_DISTRO_NAME") then
    vim.g.clipboard = {
        name = "windows-clipboard",
        copy = {
            ["*"] = "/mnt/c/WINDOWS/system32/clip.exe",
            ["+"] = "/mnt/c/WINDOWS/system32/clip.exe",
        },
        paste = {
            ["*"] = '/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ["+"] = '/mnt/c/WINDOWS/System32/WindowsPowerShell/v1.0/powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 1,
    }
end
