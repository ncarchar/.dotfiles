local M = {}

M.TBL_KEYS = function(tbl)
    local keys = {}
    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end
    return keys
end

M.NMAP = function(bufnr, keys, func, desc, mode)
    mode = mode or "n"
    desc = desc or tostring(func)
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
end

return M
