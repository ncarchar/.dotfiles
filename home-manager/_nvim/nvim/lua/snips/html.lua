local common = require "snips.common"
local ls = require "luasnip"
local s = ls.s

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep

local i = ls.insert_node
local c = ls.choice_node
local t = ls.text_node
local d = ls.dynamic_node
local sn = ls.sn

local snippets = {
    s(
        {
            trig = "mat_button",
            name = "Button | Angular Matieral",
            desc = "Standard Angular Material button. Allows for button type and color customization"
        },
        fmta(
            [[
                <<button <button_type><color><click>>><body><</button>>
            ]],
            {
                button_type = c(1, {
                    t("mat-button"),
                    t("mat-flat-button"),
                    t("mat-stroked-button"),
                    t("mat-icon-button")
                }),
                color = c(2, {
                    t(""),
                    t(" color=\"primary\""),
                    t(" color=\"accent\""),
                    t(" color=\"warn\"")
                }),
                click = c(3, {
                    t(""),
                    fmt("{}(click)=\"{}\"", {  t(" "), i(1) })
                }),
                body = d(4, function(args)
                    local button_type = args[1][1]
                    if button_type == "mat-icon-button" then
                        return sn(nil, fmta("<<mat-icon>><insert><</mat-icon>>", { insert = i(1) }))
                    else
                        return sn(nil, fmta("<insert>", { insert = i(1) }))
                    end
                end, { 1 })
            })
    ),
    s(
        {
            trig = "mat_card",
            name = "Card | Angular Matieral",
            desc = "Standard Angular Material card."
        },
        fmta(
            [[
            <<mat-card>>
                <<mat-card-header>>
                    <<mat-card-title>><title><</mat-card-title>>
                <</mat-card-header>>
                <<mat-card-content>>
                    <body>
                <</mat-card-content>>
            <</mat-card>>
        ]],
            {
                title = i(1),
                body = i(0)
            })
    ),
    s(
        {
            trig = "mat_select",
            name = "Select | Angular Matieral",
            desc = "Standard Angular Material select."
        },
        fmta(
            [[
                <<mat-form-field>>
                    <<mat-label>><label><</mat-label>>
                    <<mat-select<multiple>>>
                        @for (<item> of <items>; track <track>) {
                            <<mat-option [value]="<item_value>">>{{ <item_label> }}<</mat-option>>
                        }
                    <</mat-select>>
                <</mat-form-field>>
            ]],
            {
                label = i(1),
                multiple = c(2, {
                    t(""),
                    t(" multiple")
                }),
                item = i(3),
                items = i(4),
                track = d(5, function(args)
                    local item = args[1][1]
                    return sn(nil, i(1, item))
                end, { 3 }),
                item_value = rep(5),
                item_label = d(6, function(args)
                    local item = args[1][1]
                    if (string.find(item, ".", 1, true)) then
                        return sn(nil, fmt(item .. ".{}", { i(1, "label") }))
                    end
                    return sn(nil, i(1, item))
                end, { 3 }),
            })
    ),
    s(
        {
            trig = "mat_input",
            name = "Input | Angular Matieral",
            desc = "Standard Angular Material input."
        },
        fmta([[
                <<mat-form-field>>
                    <<mat-label>><label><</mat-label>>
                    <<input matInput type="text"/>>
                <</mat-form-field>>
            ]],
            {
                label = i(1),
            })
    ),
    s(
        {
            trig = "mat_input_clearable",
            name = "Input Clearable | Angular Matieral",
            desc = "Angular Material input with clear button when populated."
        },
        fmta([[
            <<mat-form-field>>
                <<mat-label>><label><</mat-label>>
                <<input matInput type="text" #<identifier> />>
                @if (<identifier_value>.value && <identifier_length>.value.length >> 0) {
                    <<button matSuffix mat-icon-button aria-label="Clear" (click)="<identifier_click>.value = ''">>
                        <<mat-icon>>close<</mat-icon>>
                    <</button>>
                }
            <</mat-form-field>>
        ]],
            {
                label = i(1),
                identifier = i(2, "input"),
                identifier_value = rep(2),
                identifier_length = rep(2),
                identifier_click = rep(2),
            })
    ),
    s(
        {
            trig = "mat_progress_bar",
            name = "Progress Bar | Angular Matieral",
            desc = "Angular Material progress bar wrapped with an if."
        },
        fmta([[
                @if (<logic>) {
                    <<mat-progress-bar mode="<mode>"<progress>>><</mat-progress-bar>>
                }
            ]],
            {
                logic = i(1),
                mode = c(2, {t("indeterminate"), t("determinate")}),
                progress = d(3, function(args)
                    local mode = args[1][1]
                    if (mode == "determinate") then
                        return sn(nil, fmt("{}value=\"{}\"", { t(" "), i(1) }))
                    end
                    return sn(nil, t(""))
                end, { 2 })
            })
    ),
}

common.refresh_snips("html", snippets)
