local M = {}

---@param results string[]
---@param callback fun(integer)
function M.createTelescopeWindow(results, callback, prompt_title, results_title)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values

  local max_height = 40
  local height = math.min(#results + 4, max_height)
  pickers
    .new({}, {
      prompt_title = prompt_title,
      results_title = results_title,
      finder = finders.new_table({
        results = results,
      }),
      sorter = conf.generic_sorter({}),
      layout_strategy = "center",
      layout_config = {
        width = 80,
        height = height,
        prompt_position = "bottom",
      },
      attach_mappings = function(_, map)
        map("i", "<CR>", function(prompt_bufnr)
          local selection = require("telescope.actions.state").get_selected_entry()
          require("telescope.actions").close(prompt_bufnr)
          callback(selection.index)
        end)
        return true
      end,
    })
    :find()
end

---@param options string[]
---@param callback fun(integer)
function M.createWindow(options, callback)
  local buf = vim.api.nvim_create_buf(false, true)
  local width = 80
  local max_height = 20
  local height = math.min(#options + 2, max_height)

  local ui = vim.api.nvim_list_uis()[1]

  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((ui.height - height) / 2),
    col = math.floor((ui.width - width) / 2),
    anchor = "NW",
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, false, opts)
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, options)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype = "nofile"
  vim.api.nvim_set_option_value("winhl", "Normal:MyHighlight", { win = win })
  vim.api.nvim_win_set_cursor(win, { 1, 0 })

  local function select_current_line()
    local row, _ = unpack(vim.api.nvim_win_get_cursor(win))
    vim.api.nvim_win_close(win, true)
    callback(row)
  end

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, silent = true })
  vim.keymap.set("n", "<CR>", select_current_line, { buffer = buf, silent = true })

  for i in ipairs(options) do
    vim.keymap.set("n", tostring(i), function()
      vim.api.nvim_win_close(win, true)
    end, { buffer = buf, silent = true })
  end
end

return M
