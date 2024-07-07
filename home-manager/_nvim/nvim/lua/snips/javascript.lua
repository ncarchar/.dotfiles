local common = require "snips.common"
local ls = require "luasnip"
local s = ls.s

local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node

local snippets = {
    s(
        {
            trig = "log .. var",
            name = "log"
        },
        fmt("console.log(\"{} {});",
            {
                f(function() return vim.fn.expand("%") end),
                c(1, { fmt("-> {}:\", {}", { rep(1), i(1) }), fmt("~ {}\"", { i(1) }), }),
            })
    ),
    s("for .. count",
        fmt("for (let {} = 0; {} < {}.length; {}++) {{\n\t{}\n}}",
            {
                i(1, "i"),
                rep(1),
                i(2),
                rep(1),
                i(0)
            })
    )
}

common.refresh_snips("javascript", snippets)
common.refresh_snips("typescript", snippets)
