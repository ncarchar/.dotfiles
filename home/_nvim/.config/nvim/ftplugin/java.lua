local nmap = require("lsp.nmap")

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
	signatureHelp = { enabled = true },
	completion = {
		importOrder = {
			"javax",
			"lombok",
			"com",
			"org",
			"java",
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
	flags = {
		allow_incremental_sync = true,
	},
	init_options = {
		bundles = {},
	},
}

local username = vim.fn.getenv("USER")
local mason_path = "/home/" .. username .. "/.local/share/nvim/mason"
local jdtls_package_path = mason_path .. "/packages/jdtls"
local path_to_config = jdtls_package_path .. "/config_linux"
local jar_path = find_jar_file(jdtls_package_path, "org.eclipse.equinox.launcher_")
local lombok_path = jdtls_package_path .. "/lombok.jar"
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "Dockerfile" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if root_dir == "" then
	return
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name .. "/"
if not vim.fn.isdirectory(workspace_dir) then
	os.execute("mkdir " .. workspace_dir)
end

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

local on_attach = function(client, bufnr)
	client.server_capabilities.semanticTokensProvider = nil
	nmap("<leader>oi", require("jdtls").organize_imports, "[O]rganize [I]mports", bufnr)
	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("<leader>oi", require("jdtls").organize_imports, "[O]rganize [I]mports")
	nmap("<leader>ci", vim.lsp.buf.incoming_calls, "[C]alls [I]ncoming")
	nmap("<leader>co", vim.lsp.buf.outgoing_calls, "[C]alls [O]utgoing")

	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
	nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
	nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
end

require("jdtls").start_or_attach({
	cmd = cmd,
	on_attach = on_attach,
	settings = settings,
})

vim.api.nvim_create_user_command("JdtlsClean", function()
	local workspace_root = vim.fn.stdpath("data") .. "/site/java/workspace-root/"
	if vim.fn.isdirectory(workspace_root) == 1 then
		os.execute("rm -rf " .. workspace_root .. "*")
		print("All JDT LS workspaces removed from " .. workspace_root)
	else
		print("Workspace root not found.")
	end
end, {})
