local common = require "snips.common"
local ls = require "luasnip"
local s = ls.s

local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local events = require("luasnip.util.events")

local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.sn

local function ensure_import_exists(target_import_class)
    local parser = vim.treesitter.get_parser(0, "java")
    local tree = parser:parse()[1]

    local root = tree:root()
    local query = vim.treesitter.query.parse("java", [[
    (import_declaration) @import
  ]])

    local target_import = "import " .. target_import_class .. ";"
    local import_exists = false
    local last_import_line = 0

    -- Loop through all import declarations
    for id, node in query:iter_captures(root, 0, 0, -1) do
        local text = vim.treesitter.get_node_text(node, 0)
        if text == target_import then
            import_exists = true
            break
        end
        -- Update the line number of the last import statement found
        local start_row, end_row = node:range()
        last_import_line = start_row
    end

    -- If the import does not exist, add it after the last import
    if not import_exists then
        -- Adjust because we tracked the end_row of the last import
        local insert_position = last_import_line + 1
        vim.api.nvim_buf_set_lines(0, insert_position, insert_position, false, { target_import })
    end

    return import_exists
end

local function get_package(package_path)
    -- Check if package_path is nil or empty
    if package_path == nil or package_path == "" then
        return ""
    end

    -- Ensure package_path manipulation doesn't result in a nil or non-numeric value
    package_path = package_path:gsub("/[^/]+%.java$", "")
    if package_path == nil or package_path == "" then
        return ""
    end

    local package_name = package_path:gsub("/", ".")
    -- Further checks can be added here if necessary

    return "package " .. package_name .. ";"
end

local snippets = {
    s(
        {
            trig = "log .. var",
            name = "log"
        },
        fmt("log.info(\"{}: \" + {});", {
            rep(1),
            i(1),
        }
        )
    ),
    s("log .. level",
        fmt("log.{}({});", {
            c(1, { t("info"), t("warning"), t("severe") }),
            i(2),
        }
        )
    ),
    s("for .. count",
        fmt("for (int {} = 0; {} < {}.size(); {}++) {{\n\t{}\n}}",
            {
                i(1, "i"),
                rep(1),
                i(2),
                rep(1),
                i(0)
            })
    ),
    s("try .. catch",
        fmt("try {{\n\t{}\n}} catch({} e) {{\n\tlog.severe(\"{} in {}:\" + e.getMessage());\n}}",
            {
                i(1),
                i(2, "Exception"),
                rep(2),
                f(function() return vim.fn.expand("%:t:r") end)
            })
    ),
    s(
        {
            name = "_service"
        },
        fmta(
            [[
                <package>

                import org.springframework.stereotype.Service;
                import lombok.extern.java.Log;

                @Log
                @Service
                public class <class_name> <implements> {
                    <body>
                }
            ]],
            {
                package = f(function(_, opts)
                    local path = opts.env.TM_PATH
                    if not path:match("/java/") then return "" end
                    local start_index = path:find("/java/") + 6
                    local package_path = path:sub(start_index)
                    if package_path ~= nil then return get_package(package_path) end
                    return ""
                end),
                class_name = f(function(_, opts) return string.gsub(opts.env.TM_FILENAME, ".java", "") end),
                implements = f(function(_, opts)
                    local file_name = opts.env.TM_FILENAME
                    if file_name:match("Impl") then
                        return "implements " .. file_name:gsub("Impl.java", "")
                    end
                    return ""
                end),
                body = i(0)
            })
    ),
    s("autowired",
        fmt(
            [[
                @Autowired
                {} {};
            ]],
            {
                i(1),
                f(function(args)
                    local class_name = args[1][1]
                    if class_name then
                        return common.lower_first_letter(class_name)
                    else
                        return ""
                    end
                end, { 1 })
            }),
        {
            callbacks = {
                [-1] = {
                    [events.enter] = function(node, _event_args)
                        ensure_import_exists("org.springframework.beans.factory.annotation.Autowired")
                    end
                },
            }
        }
    )
}

common.refresh_snips("java", snippets)

return {
    ensure_import_exists = ensure_import_exists,
    get_package = get_package
}
