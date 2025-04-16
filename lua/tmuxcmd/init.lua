local Window = require("tmuxcmd.window")

local M = {}

function M.setup(_) end

---@type table<string, table<string, string>>
local commands = {
  cs = {
    ["Build with only errors"] = "dotnet build /property:WarningLevel=0",
    ["Build and Test"] = "dotnet build --interactive && dotnet test",
  },
  go = {
    ["Test"] = "go test ./...",
    ["Generate coverage"] = "make test-coverage",
  },
  lua = {
    ["LuaTest"] = "ls",
  },
}

function M.openMainMenu()
  local filetype = vim.bo.filetype
  local options = commands[filetype] or {}

  local selections = { "Open in VSCode" }
  for k in pairs(options) do
    table.insert(selections, k)
  end

  ---@param row integer
  local function select_current_line(row)
    local choice = selections[row]
    if choice then
      M.executeCommand(choice)
    end
  end

  Window.createTelescopeWindow(selections, select_current_line, nil, "Available Commands")
end

local function executeCommand(command)
  vim.fn.system('tmux send-keys -t scratch "' .. command .. '" ^M')
end

function M.executeCommand(command)
  if command == "Open in VSCode" then
    local cmd = "code ."
    executeCommand(cmd)
    return
  end
  local filetype = vim.bo.filetype
  local cmd = commands[filetype][command]

  executeCommand(cmd)
  vim.fn.system("tmux select-window -t scratch")
end

vim.api.nvim_create_user_command("Tmuxcmd", function()
  M.openMainMenu()
end, { nargs = "*", desc = "Tmuxcmd plugin" })

return M
