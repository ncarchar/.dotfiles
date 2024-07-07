local common = require "snips.common"
local ls = require "luasnip"
local s = ls.s
local f = ls.function_node

local snippets = {
    s("current_timestamp", f(function() return os.date "%Y-%m-%d %H:%M:%S" end))
}

common.refresh_snips("all", snippets)
