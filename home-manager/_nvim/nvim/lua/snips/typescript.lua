local common = require "snips.common"
local ls = require "luasnip"
local s = ls.s

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local events = require("luasnip.util.events")

local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.sn


local snippets = {
    s("imp",
        fmta(
            [[
                private readonly <name>: <import>
            ]],
            {
                import = i(1),
                name = d(2, function(args)
                    local import = args[1][1]
                    return sn(nil, c(1, {t(""),t(common.lower_first_letter(import))}) )
                end, { 1 })
            }
        ),
        {
            callbacks = {
                [-1] = {
                    [events.leave] = function(node, _event_args)
                        print("node" .. TBL_STRING(node))
                        print("_event_args" .. TBL_STRING(_event_args))
                    end
                },
            }
        }
    ),
    s(
        {
            trig = "constructor",
            name = "Constructor | Angular Constructor",
            desc = "Constructor for Angular."
        },
        fmt(
            [[
                constructor({}) {{
                    {}
                }}
            ]],
            {
                i(1),
                i(0)
            })
    ),
    s(
        {
            trig = "ng_on_init",
            name = "On Init | Angular Lifecycle Hook",
            desc = "Angular ngOnInit."
        },
        fmt(
            [[
                ngOnInit(): void {{
                    {}
                }}
            ]],
            {
                i(0)
            })
    ),
    s(
        {
            trig = "ng_after_view_init",
            name = "After View Init | Angular Lifecycle Hook",
            desc = "Angular ngAfterViewInit."
        },
        fmt(
            [[
                ngAfterViewInit(): void {{
                    {}
                }}
            ]],
            {
                i(0)
            })
    ),
    s(
        {
            trig = "ng_on_changes",
            name = "On Changes | Angular Lifecycle Hook",
            desc = "Angular ngOnChages with some simple templating."
        },
        fmta(
            [[
                ngOnChanges(changes: SimpleChanges): void {
                    if (changes["inputValue"] && changes["inputValue"].currentValue != changes["inputValue"].previousValue) {
                        <body>
                    }
                }
                ]],
            {
                body = i(0)
            })
    ),
    s(
        {
            trig = "until_destroy",
            name = "Take Until ngOnDestroy",
            desc = "Use with subscriptions to destroy with component."
        },
        fmt("{}",
            {
                c(1, { t(".pipe(takeUntil(onDestroy$))"), t(", takeUntil(onDestroy$)") })
            })
    ),
    s(
        {
            trig = "ng_on_destroy",
            name = "On Destroy | Angular Lifecycle Hook",
            desc = "Angular ngOnDestroy with subject to destroy subscriptions. Use .pipe(takeUntil(onDestroy$))."
        },
        fmt(
            [[
                {}
                private readonly onDestroy$ = new Subject<void>();
                ngOnDestroy(): void {{
                    this.onDestroy$.next();
                    this.onDestroy$.complete();
                }}
            ]],
            {
                i(0)
            })
    ),
}

common.refresh_snips("typescript", snippets)
