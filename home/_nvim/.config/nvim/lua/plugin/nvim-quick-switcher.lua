return {
	{
		"Everduin94/nvim-quick-switcher",
		config = function()
			local function find(file_regex, opts)
				return function()
					require("nvim-quick-switcher").find(file_regex, opts)
				end
			end

			local function find_by_fn(fn, opts)
				return function()
					require("nvim-quick-switcher").find_by_fn(fn, opts)
				end
			end

			local function map(buf, lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
			end

			-- Angular
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "typescript", "htmlangular", "html", "css", "scss" },
				callback = function(args)
					map(
						args.buf,
						"<leader>at",
						find(".component.ts"),
						"Component [T]S"
					)
					map(
						args.buf,
						"<leader>as",
						find(".+css|.+scss", { regex = true, prefix = "full" }),
						"[A]ngular Component [S]CSS"
					)
					map(args.buf, "<leader>ah", find(".+html", { regex = true, prefix = "full" }), "Component [H]TML")
					map(args.buf, "<leader>au", find(".component.spec.ts"), "Tests")
				end,
			})

			-- Java
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "java" },
				callback = function(args)
					local opts = { only_existing = true, only_existing_notify = true }

					local function ensure_path(path, p)
						local dir = vim.fn.fnamemodify(path, ":h")
						if vim.fn.isdirectory(dir) == 0 then
							vim.fn.mkdir(dir, "p")
						end
						if vim.fn.filereadable(path) == 0 then
							if
								vim.fn.confirm("File does not exist at " .. path .. "\nCreate it?", "&Yes\n&No", 1) == 1
							then
								local fd = io.open(path, "w")
								if fd then
									fd:close()
								end
							end
						end
					end

					local to_test = function(p)
						local base = p.path:gsub("/src/main/java/", "/src/test/java/", 1)
						local target = base .. "/" .. p.prefix .. "Test.java"
						ensure_path(target, p)
						return target
					end

					local to_main = function(p)
						local base = p.path:gsub("/src/test/java/", "/src/main/java/", 1)
						local target = base .. "/" .. p.prefix:gsub("Test$", "") .. ".java"
						return target
					end

					map(args.buf, "<leader>at", find_by_fn(to_main, opts), "Main")
					map(args.buf, "<leader>au", find_by_fn(to_test, opts), "Tests")
				end,
			})
		end,
	},
}
