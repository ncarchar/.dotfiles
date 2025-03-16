return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'ThePrimeagen/harpoon' },
        config = function()
            local palette = require('onedark.palette').dark
            local lualine = require("lualine")

            lualine.setup {
                options = {
                    component_separators = { left = "|", right = "|" },
                    section_separators = { left = "", right = "" },
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
                    lualine_y = { "progress" },
                    lualine_z = { "location" }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {}
                },
            }
        end
    }
}
