local ls = require "luasnip"

local M = {}

function M.refresh_snips(key, snippets)
    require("luasnip.session.snippet_collection").clear_snippets(key)
    --ls.add_snippets(key, { table.unpack(snippets) })
end

function M.lower_first_letter(value)
    if value == nil then
        return ""
    end
    return (value:gsub("^.", function(firstletter)
        return firstletter:lower()
    end))
end

return M
