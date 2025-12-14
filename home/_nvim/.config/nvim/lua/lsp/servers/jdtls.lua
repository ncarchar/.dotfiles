local M = {}

local function glob_one(pattern)
    local matches = vim.fn.glob(pattern, true, true)
    if type(matches) == "table" and #matches > 0 then
        table.sort(matches)
        return matches[#matches]
    end
    return ""
end

local function ensure_dir(path)
    if vim.fn.isdirectory(path) == 0 then
        vim.fn.mkdir(path, "p")
    end
end

local WORKSPACE_ROOT = vim.fn.stdpath("data") .. "/jdtls-workspace/"
ensure_dir(WORKSPACE_ROOT)

function M.setup()
    local root_markers = { "mvnw", "gradlew", "pom.xml" }
    local root_dir = require("jdtls.setup").find_root(root_markers)
    if root_dir == nil or root_dir == "" then
        return
    end

    local home = vim.env.HOME or vim.fn.expand("$HOME")
    local mason_path = home .. "/.local/share/nvim/mason"
    local jdtls_package_path = mason_path .. "/packages/jdtls"

    local path_to_config = jdtls_package_path .. "/config_linux"
    local lombok_path = jdtls_package_path .. "/lombok.jar"
    local jar_path = glob_one(jdtls_package_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    if jar_path == "" then
        vim.notify("jdtls jar not found under mason packages", vim.log.levels.ERROR)
        return
    end

    local project_name = vim.fs.basename(root_dir)
    local workspace_dir = WORKSPACE_ROOT .. project_name
    ensure_dir(workspace_dir)

    local settings = {
        java = {
            eclipse = { downloadSources = true },
            configuration = { updateBuildConfiguration = "interactive" },
            maven = { downloadSources = true },
            implementationsCodeLens = { enabled = true },
            referencesCodeLens = { enabled = true },
            references = { includeDecompiledSources = true },
            format = { enabled = true },
            signatureHelp = { enabled = true },
            completion = {
                importOrder = { "java", "javax", "net", "com", "org" },
            },
            codeGeneration = {
                useBlocks = true,
            },
        },
    }

    local cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-javaagent:" .. lombok_path,
        "-Xms256m",
        "-Xmx2g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        jar_path,
        "-configuration",
        path_to_config,
        "-data",
        workspace_dir,
    }

    return {
        filetypes = { "java" },
        cmd = cmd,
        root_dir = root_dir,
        settings = settings,
        on_attach = function(client, bufnr)
            client.server_capabilities.semanticTokensProvider = nil
            local nmap = require("utils").NMAP
            nmap(bufnr, "<leader>oi", require("jdtls").organize_imports, "[O]ranize [I]mports")
        end,
    }
end

vim.api.nvim_create_user_command("JdtlsClean", function()
    local workspace_root = vim.fn.stdpath("data") .. "/jdtls-workspace/"
    if vim.fn.isdirectory(workspace_root) == 1 then
        os.execute("rm -rf " .. workspace_root .. "*")
        print("All JDT LS workspaces removed from " .. workspace_root)
    else
        print("Workspace root not found.")
    end
end, {})

return M
