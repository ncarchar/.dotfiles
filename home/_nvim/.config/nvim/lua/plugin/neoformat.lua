return {
    {
        "sbdchd/neoformat",
        lazy = true,
        event = "BufEnter",
        config = function()
            local generics = require("utils.generics")
            vim.g.neoformat_run_all_formatters = 0

            local BIOME_ROOT_MARKERS = { "biome.json", "biome.jsonc" }

            local TOOLS = {
                biome = {
                    priority = 100,
                    filetypes = { "typescript", "javascript", "json" },
                    root_markers = BIOME_ROOT_MARKERS,
                },
                prettier = {
                    priority = 50,
                    filetypes = {
                        "typescript",
                        "javascript",
                        "json",
                        "htmlangular",
                    },
                },
                jdtls = {
                    priority = 100,
                    filetypes = { "java" },
                },
                lemminx = {
                    priority = 100,
                    filetypes = { "xml" },
                },
                bashls = {
                    priority = 100,
                    filetypes = { "sh" },
                },
                stylua = {
                    priority = 100,
                    filetypes = { "lua" },
                },
            }

            local function has_root_file(server_name, filenames)
                if not filenames or #filenames == 0 then
                    return true
                end

                local clients = vim.lsp.get_clients({ bufnr = 0 })
                for _, client in ipairs(clients) do
                    local root_dir = client.config.root_dir or client.root_dir
                    if root_dir and client.name == server_name then
                        for _, filename in ipairs(filenames) do
                            if vim.loop.fs_stat(root_dir .. "/" .. filename) then
                                return true
                            end
                        end
                    end
                end

                local found = vim.fs.find(filenames, {
                    path = vim.fn.expand("%:p:h"),
                    upward = true,
                    stop = vim.env.HOME,
                })
                return #found > 0
            end

            local function lsp_formatter_available(server_name)
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                for _, client in ipairs(clients) do
                    if
                        client.name == server_name
                        and client:supports_method("textDocument/formatting")
                    then
                        return true
                    end
                end
                return false
            end

            local function resolve_formatter(filetype)
                local current_best_name = nil
                local current_best_priority = -1

                for tool_name, config in pairs(TOOLS) do
                    if vim.tbl_contains(config.filetypes, filetype) then
                        if config.priority > current_best_priority then
                            if has_root_file(tool_name, config.root_markers) then
                                current_best_name = tool_name
                                current_best_priority = config.priority
                            end
                        end
                    end
                end

                return current_best_name
            end

            local function format_buffer()
                local filetype = vim.bo.filetype
                local fmt_name = resolve_formatter(filetype)

                if not fmt_name then
                    print("No applicable formatter found for " .. filetype)
                    return
                end

                if lsp_formatter_available(fmt_name) then
                    vim.lsp.buf.format({
                        bufnr = vim.api.nvim_get_current_buf(),
                        filter = function(client)
                            return client.name == fmt_name
                        end,
                    })
                else
                    vim.cmd("Neoformat " .. fmt_name)
                end
            end

            require("mason-tool-installer").setup({
                ensure_installed = generics.TBL_KEYS(TOOLS),
            })
            vim.keymap.set(
                "n",
                "<leader>fl",
                format_buffer,
                { noremap = true, desc = "Format buffer" }
            )
        end,
    },
}
