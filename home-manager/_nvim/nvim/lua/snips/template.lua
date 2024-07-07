local ls = require "luasnip"

local get_snip_info = function(file_name)
    if string.find(file_name, ".java") then
        if string.find(file_name, "Service") then
            return 'java', "_service"
        end
    end
end

local open_file_in_background = function(file_path)
    -- Create a new buffer without displaying it
    local buf = vim.api.nvim_create_buf(false, true)

    if vim.fn.filereadable(file_path) == 1 then
        print("File already exists.")
        return
    end

    return buf
end

vim.api.nvim_create_user_command('FTemplate', function(opts)
    local file_name = opts.args
    if file_name == nil then
        print("Must provide a file name e.x. Template MyFile.java")
        return
    end

    local type, snip_name = get_snip_info(file_name);

    if snip_name == nil or type == nil then
        print("Unable to id a template snip.")
        return
    end

    local current_file_dir = vim.fn.expand('%:p:h') .. "/"
    local file_path = current_file_dir .. file_name
    local buf_id = open_file_in_background(file_path)

    if buf_id == nil then
        print("buf_id is nil.")
        return
    end


    vim.api.nvim_buf_call(buf_id, function()
        vim.cmd('silent AddFileSnip ' .. file_name .. ' ' .. file_path .. ' ' .. snip_name .. ' ' .. type)
    end)

    vim.api.nvim_buf_call(buf_id, function()
        vim.cmd("silent w " .. file_path)
    end)

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), 'x', true)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, false, true), 'x', true)
end, { nargs = 1 })

vim.api.nvim_create_user_command('AddFileSnip', function(args)
    local luasnip = require("luasnip")
    local file_name = args.fargs[1]
    local file_path = args.fargs[2]
    local name = args.fargs[3]
    local type = args.fargs[4]

    if name == nil then
        print("Name must be provided.")
        return
    end

    if type == nil then
        type = ""
    end

    local snips = ls.get_snippets(type)
    if snips == nil then
        print("No snippets found for type: " .. type)
        return
    end

    local found_snip = nil
    for _, snippet in ipairs(snips) do
        if snippet.name == name then
            found_snip = snippet
            break
        end
    end

    if found_snip then
        print("Snippet found")
    else
        print("Snippet with name '" .. name .. "' not found.")
    end
    local opts = {}
    opts.expand_params = {
        env_override = {
            TM_FILENAME = file_name,
            TM_PATH = file_path
        }
    }

    luasnip.snip_expand(found_snip, opts)
end, { nargs = "*" })
