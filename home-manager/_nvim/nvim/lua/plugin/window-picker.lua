require ('window-picker').setup({
    hint = 'statusline-winbar',
    selection_chars = 'FJDKSLA;CMRUEIWOQP',
    -- This section contains picker specific configurations
    picker_config = {
        statusline_winbar_picker = {
           selection_display = function(char, windowid)
                return '%=' .. char .. '%='
            end,

            -- whether you want to use winbar instead of the statusline
            -- "always" means to always use winbar,
            -- "never" means to never use winbar
            -- "smart" means to use winbar if cmdheight=0 and statusline if cmdheight > 0
            use_winbar = 'smart', -- "always" | "never" | "smart"
        },
    },
    -- whether to show 'Pick window:' prompt
    show_prompt = false,
    -- prompt message to show to get the user input
    prompt_message = '',
    -- if you want to manually filter out the windows, pass in a function that
    -- takes two parameters. You should return window ids that should be
    -- included in the selection
    -- EX:-
    -- function(window_ids, filters)
    --    -- folder the window_ids
    --    -- return only the ones you want to include
    --    return {1000, 1001}
    -- end
    filter_func = nil,
    -- following filters are only applied when you are using the default filter
    -- defined by this plugin. If you pass in a function to "filter_func"
    -- property, you are on your own
    filter_rules = {
        -- when there is only one window available to pick from, use that window
        -- without prompting the user to select
        autoselect_one = true,

        -- whether you want to include the window you are currently on to window
        -- selection or not
        include_current_win = false,

        -- filter using buffer options
        bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { 'NvimTree', 'neo-tree', 'notify' },
            -- if the file type is one of following, the window will be ignored
            buftype = { 'terminal' },
        },
        -- filter using window options
        wo = {},
        -- if the file path contains one of following names, the window
        -- will be ignored
        file_path_contains = {},
        -- if the file name contains one of following names, the window will be
        -- ignored
        file_name_contains = {},
    },

    -- You can pass in the highlight name or a table of content to set as
    -- highlight
    highlights = {
        statusline = {
            focused = {
                fg = '#181a1f',
                bg = '#98C379',
                bold = true,
            },
            unfocused = {
                fg = '#181a1f',
                bg = '#98C379',
                bold = true,
            },
        },
        winbar = {
            focused = {
                fg = '#181a1f',
                bg = '#98C379',
                bold = true,
            },
            unfocused = {
                fg = '#181a1f',
                bg = '#98C379',
                bold = true,
            },
        },
    },
})


function _G.switch_to_window_id(id)
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
        if win == id then
            vim.api.nvim_set_current_win(win)
            return
        end
    end
end

function _G.isValidWindowId(id)
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
        if win == id then
            return true
        end
    end
    return false
end

function _G.safe_switch_to_window()
    local window_id = require("window-picker").pick_window()
    if _G.isValidWindowId(window_id) then
        _G.switch_to_window_id(window_id)
    end
end

vim.api.nvim_set_keymap('n', '<leader>w', ':lua _G.safe_switch_to_window()<CR>', {noremap = true, silent = true})

