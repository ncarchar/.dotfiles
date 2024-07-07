local function get_git_project_name()
  local handle = io.popen('git rev-parse --show-toplevel 2> /dev/null')
  if handle == nil then
    return
  end
  local git_root = handle:read("*a")
  handle:close()
  if git_root == "" then
    return nil
  else
    git_root = git_root:gsub("\n", "")
    local project_name = git_root:match("^.+/(.+)$")
    return project_name
  end
end

-- Passthrough taskwarrior appends git project name
vim.api.nvim_create_user_command('Task', function(args)
  local project_name = get_git_project_name()
  if project_name then
    vim.cmd('!task project:' .. project_name .. ' ' .. args.args)
  else
    vim.cmd('!task ' .. args.args)
  end
end, { nargs = '*' })
