local nmap = require('lsp.nmap')

local M = {}

local function find_jar_file(package_path, package_name)
    local command = string.format("ls %s/plugins/%s*.jar", package_path, package_name)
    local handle = io.popen(command)
    if handle == nil then
        return ""
    end
    local result = handle:read("*a")
    handle:close()
    return string.match(result, "[^\r\n]+")
end

M.setup = function(_on_attach, _capabilities)
    local settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            format = {
                enabled = true,
            },
        },
        signatureHelp = { enabled = false },
        completion = {
            importOrder = {
                "java",
                "javax",
                "lombok",
                "com",
                "org"
            },
        },
        sources = {
            organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
            },
        },
        codeGeneration = {
            toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
        },
    }


    local username = vim.fn.getenv("USER")
    local mason_path = '/home/' .. username .. '/.local/share/nvim/mason'
    local jdtls_package_path = mason_path .. "/packages/jdtls/"
    local path_to_config = jdtls_package_path .. "/config_linux"
    local jar_path = find_jar_file(jdtls_package_path, "org.eclipse.equinox.launcher_")
    local lombok_path = jdtls_package_path .. "lombok.jar"
    local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "Dockerfile" }
    local root_dir = require("jdtls.setup").find_root(root_markers)
    if root_dir == "" then
        return
    end

    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. project_name
    if not vim.fn.isdirectory(workspace_dir) then
        os.execute("mkdir " .. workspace_dir)
    end

    local cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-javaagent:' .. lombok_path,
        '-Xms1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
        '-jar', jar_path,
        '-configuration', path_to_config,
        '-data', workspace_dir,
    }


    local on_attach = function(client, bufnr)
        _on_attach(client, bufnr)
        client.server_capabilities.semanticTokensProvider = nil
        nmap('<leader>oi', require('jdtls').organize_imports, '[O]rganize [I]mports', bufnr)
    end


    _capabilities.textDocument.completion.completionItem.snippetSupport = false
    require('lspconfig').jdtls.setup {
        cmd = cmd,
        on_attach = on_attach,
        capabilities = _capabilities,
        settings = settings
    }
end

return M
