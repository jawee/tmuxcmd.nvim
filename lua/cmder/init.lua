local Window = require("cmder.window")

local M = {}

function M.setup()
end

function M.openMainMenu()
  local options = {
    "Build with only errors",
    "Build and Test",
  }

  ---@param row integer
  local function select_current_line(row)
    local choice = options[row]
    if choice then
      M.executeCommand(choice)
    end
  end

  Window.createTelescopeWindow(options, select_current_line, nil, "Available Commands")
end

function M.executeCommand(command)
  if command == "Build and Test" then
    vim.fn.system("tmux send-keys -t scratch \"dotnet build --interactive && dotnet test\" ^M")
  elseif command == "Build with only errors" then
    vim.fn.system("tmux send-keys -t scratch \"dotnet build /property:WarningLevel=0\" ^M")
  end
  vim.fn.system("tmux select-window -t scratch")
end

vim.api.nvim_create_user_command("Cmder", function()
  M.openMainMenu()
end, { nargs = "*", desc = "Cmder plugin" })

return M
