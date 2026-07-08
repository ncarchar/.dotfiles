local M = {}

local get_root = function(bufnr, file_type)
    local parser = vim.treesitter.get_parser(bufnr, file_type, {})
    local tree = parser:parse()[1]
    return tree:root()
end

M.go_to_node = function(file_type, query, goto_end, avoid_set_jump)
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].filetype ~= file_type then
        return
    end

    local root = get_root(bufnr, file_type)
    for id, node in query:iter_captures(root, bufnr, 0, -1) do
        local range = { node:range() }
        local row = goto_end and range[3] or range[1]
        local col = goto_end and range[4] or range[2]
        if not avoid_set_jump then
            vim.cmd("normal! m'")
        end
        vim.api.nvim_win_set_cursor(0, { row + 1, col })
        return
    end
end

return M
