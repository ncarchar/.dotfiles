-- Key map for new tab git fugitive
vim.keymap.set(
    "n",
    "<leader><leader>g",
    ":tab Git<CR>",
    { noremap = true, silent = true, desc = "[G]it Fugitive Tab" }
)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.open_float()
end, { noremap = true, silent = true, desc = "Show diagnostics" })

-- Move line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Replace Remap
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Keeps current row at the center of the screen as you navigate
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("n", "n", "nzz", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { noremap = true, silent = true })

-- See `:help vim.keymap.set()`
-- Use space for leader
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Find and replace current word
vim.keymap.set(
    "n",
    "<leader>rt",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "[R]ename [T]ext", noremap = true }
)
vim.keymap.set(
    "n",
    "<leader>rl",
    [[:s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "[R]ename [L]ine", noremap = true }
)

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})

vim.keymap.set("n", "<leader>%", function()
    vim.cmd(":w")
    vim.cmd("source %")
end, { desc = "[S]ource [%]" })

local function run_command()
    local cwd = vim.fn.getcwd()
    local run_sh_path = cwd .. "/run.sh"
    if vim.fn.filereadable(run_sh_path) == 1 then
        vim.cmd("!echo && bash " .. run_sh_path)
    else
        print("No .run.sh found in the current directory.")
    end
end

vim.keymap.set("n", "<leader><leader>r", run_command, { noremap = true, silent = true })

vim.api.nvim_create_user_command("WA", "wa", {})
vim.api.nvim_create_user_command("Wa", "wa", {})
vim.api.nvim_create_user_command("Q", "q", {})

vim.keymap.set(
    "n",
    "<leader>td",
    ":edit ~/.todo/TODO.md<CR>",
    { desc = "Edit TODO.md", noremap = true, silent = true }
)
local todo_dir = vim.fn.expand("~/todo")
local todo_file = todo_dir .. "/todo.md"

local function is_todo_buffer(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr or 0)
    return vim.fn.fnamemodify(name, ":p") == vim.fn.fnamemodify(todo_file, ":p")
end

local function is_task(line)
    return line:match("^%s*[-+*]%s+%[[ xX]%]") ~= nil
end

local function is_done(line)
    return line:match("^%s*[-+*]%s+%[[xX]%]") ~= nil
end

local function task_text(line)
    return line:gsub("^%s*[-+*]%s+%[[ xX]%]%s*", "")
end

local function todo_sort()
    if not is_todo_buffer(0) then
        vim.notify("only in todo.md", vim.log.levels.WARN)
        return
    end
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local tasks = {}
    for _, line in ipairs(lines) do
        if is_task(line) then
            table.insert(tasks, { line = line, text = task_text(line), done = is_done(line) })
        end
    end
    table.sort(tasks, function(a, b)
        if a.done ~= b.done then
            return not a.done
        end
        return a.text < b.text
    end)
    local n = 1
    for i, line in ipairs(lines) do
        if is_task(line) then
            lines[i] = tasks[n].line
            n = n + 1
        end
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.notify("sorted " .. #tasks .. " tasks", vim.log.levels.INFO)
end

local function todo_archive()
    if not is_todo_buffer(0) then
        vim.notify("only in todo.md", vim.log.levels.WARN)
        return
    end
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local week = os.date("%G-W%V")

    -- Everything from the first "## YYYY-Www" header down is already archived.
    local archive_start = nil
    for i, line in ipairs(lines) do
        if line:match("^## %d+-W%d+$") then
            archive_start = i
            break
        end
    end

    local active, archive = {}, {}
    if archive_start then
        for i = 1, archive_start - 1 do
            active[#active + 1] = lines[i]
        end
        for i = archive_start, #lines do
            archive[#archive + 1] = lines[i]
        end
    else
        for _, line in ipairs(lines) do
            active[#active + 1] = line
        end
    end

    local kept, done = {}, {}
    for _, line in ipairs(active) do
        if is_done(line) then
            done[#done + 1] = line
        else
            kept[#kept + 1] = line
        end
    end
    if #done == 0 then
        return
    end
    while #kept > 0 and kept[#kept]:match("^%s*$") do
        table.remove(kept)
    end

    -- Most recently completed closest to the top.
    local reversed_done = {}
    for i = #done, 1, -1 do
        reversed_done[#reversed_done + 1] = done[i]
    end
    done = reversed_done

    local week_header = "## " .. week

    -- Parse existing archive into week sections (blank lines get regenerated).
    local sections = {}
    local current = nil
    for _, line in ipairs(archive) do
        local header = line:match("^(## %d+-W%d+)$")
        if header then
            current = { header = header, items = {} }
            sections[#sections + 1] = current
        elseif current and not line:match("^%s*$") then
            current.items[#current.items + 1] = line
        end
    end

    -- Put this week's done items at the top of their section, or add the section.
    local found = false
    for _, sec in ipairs(sections) do
        if sec.header == week_header then
            local merged_items = {}
            for _, d in ipairs(done) do
                merged_items[#merged_items + 1] = d
            end
            for _, item in ipairs(sec.items) do
                merged_items[#merged_items + 1] = item
            end
            sec.items = merged_items
            found = true
            break
        end
    end
    if not found then
        table.insert(sections, 1, { header = week_header, items = done })
    end

    -- Canonical layout: blank before each header, blank after each header.
    local out = {}
    for _, line in ipairs(kept) do
        out[#out + 1] = line
    end
    if #sections > 0 then
        if #out > 0 and out[#out]:match("%S") then
            out[#out + 1] = ""
        end
        for i, sec in ipairs(sections) do
            if i > 1 then
                out[#out + 1] = ""
            end
            out[#out + 1] = sec.header
            out[#out + 1] = ""
            for _, item in ipairs(sec.items) do
                out[#out + 1] = item
            end
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, out)
    vim.notify("archived " .. #done .. " tasks to week " .. week, vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
    callback = function(args)
        if not is_todo_buffer(args.buf) then
            return
        end
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "<leader>st", function()
            vim.fn.mkdir(todo_dir, "p")
            require("telescope.builtin").live_grep({ cwd = todo_dir })
        end, opts)
        vim.keymap.set("n", "<leader>ta", todo_archive, opts)
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function(args)
        if is_todo_buffer(args.buf) then
            todo_archive()
        end
    end,
})

vim.api.nvim_create_user_command("TodoArchive", todo_archive, {})
vim.api.nvim_create_user_command("TodoSort", todo_sort, {})
-- Make executable
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "sh", "zsh" },
    callback = function()
        vim.keymap.set(
            "n",
            "<leader>x",
            "<cmd>!chmod +x %<CR>",
            { desc = "Make executable", noremap = true, silent = true }
        )
    end,
})

-- CD Commands
local aug = vim.api.nvim_create_augroup("CwdHelpers", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
    group = aug,
    once = true,
    callback = function()
        vim.g.initial_cwd = vim.fn.getcwd()
    end,
})

local function cd_to_buf_dir()
    local name = vim.api.nvim_buf_get_name(0)
    if name == "" then
        return
    end
    local dir = vim.fn.fnamemodify(name, ":p:h")
    print("cd: " .. dir)
    vim.cmd.cd(vim.fn.fnameescape(dir))
end

local function cd_to_initial()
    local dir = vim.g.initial_cwd
    if type(dir) ~= "string" or dir == "" then
        return
    end
    print("restore: " .. dir)
    vim.cmd.cd(vim.fn.fnameescape(dir))
end

vim.keymap.set("n", "<leader>cd", cd_to_buf_dir, { desc = "cd to current file dir" })
vim.keymap.set("n", "<leader>cD", cd_to_initial, { desc = "cd to initial cwd" })
vim.keymap.set("n", "<leader>cp", function()
    vim.fn.setreg("*", vim.fn.expand("%:p"))
end, { desc = "cp current file path" })

-- Alias LspInfo and LspLog since it was dropped by nvim-lspconfig
vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {})
vim.api.nvim_create_user_command("LspLog", function()
    local log_file = vim.lsp.log.get_filename()
    vim.cmd("tabedit " .. log_file)
    local buf = vim.api.nvim_get_current_buf()
    vim.keymap.set("n", "q", "<cmd>tabclose<cr>", { buffer = buf, silent = true })
end, {})

vim.keymap.set("n", "<leader>P", function()
    local path = vim.fn.system("realpath " .. vim.fn.shellescape(vim.fn.expand("%")))
    path = path:gsub("\n$", "")
    vim.fn.setreg("+", path)
    vim.notify(path)
end)
