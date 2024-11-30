P = function(tbl)
    print(vim.inspect(tbl))
    return tbl
end

RELOAD = function(...)
    return require('plenary.reload').reload_module(...)
end

R = function(name)
    RELOAD(name)
    print(name .. " reloaded")
    return require(name)
end

TBL_STRING = function(tbl, recurse, indent)
    if not recurse then recurse = false end
    if not indent then indent = "" end
    if not tbl then return "nil" end
    if type(tbl) ~= "table" then return tostring(tbl) end

    local result, nextIndent = "{", indent .. "  "
    for k, v in pairs(tbl) do
        if type(k) == "string" then k = '"' .. k .. '"' end
        local valueStr
        if type(v) == "table" then
            if recurse then
                valueStr = TBL_STRING(v, recurse, nextIndent)
            end
            valueStr = " {tbl..} "
        else
            if type(v) == "string" then v = '"' .. v .. '"' end
            valueStr = tostring(v)
        end
        result = result .. nextIndent .. "[" .. k .. "] = " .. valueStr .. ","
    end
    return result .. indent .. "}"
end
