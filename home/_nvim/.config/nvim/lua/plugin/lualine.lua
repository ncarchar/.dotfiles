local palette = require('onedark.palette').dark

require("lualine").setup {
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "|", right = "|" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 200,
            tabline = 200,
            winbar = 200,
        }
    },
    sections = {
        lualine_a = {},
        lualine_b = {
            {
                "harpoon2",
                indicators = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
                active_indicators = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
                color_active = { fg = palette.red, gui = "bold" },
                _separator = " ",
                no_harpoon = "--",
            },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "diagnostics" },
        lualine_y = { "location" },
        lualine_z = { { "datetime", style = "%H:%M:%S" } }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 1 } },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}
