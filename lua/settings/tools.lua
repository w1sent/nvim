

local function copy_qf_files_to_location(opts)
  opts = opts or {}
  local move_files = opts.move or false
  local destination = opts.args or opts.destination

  if not destination or destination == "" then
    vim.notify("Error: No destination specified", vim.log.levels.ERROR)
    return
  end

  -- Expand the destination path
  destination = vim.fn.expand(destination)

  -- Create destination directory if it doesn't exist
  vim.fn.mkdir(destination, "p")

  -- Get quickfix list
  local qf_list = vim.fn.getqflist()

  if #qf_list == 0 then
    vim.notify("Quickfix list is empty", vim.log.levels.WARN)
    return
  end

  local new_qf_list = {}
  local success_count = 0

  for _, item in ipairs(qf_list) do
    local source_path = vim.fn.bufname(item.bufnr)

    if source_path and source_path ~= "" then
      local filename = vim.fn.fnamemodify(source_path, ":t")
      local dest_path = destination .. "/" .. filename

      -- Copy or move the file
      local cmd = move_files and string.format("mv '%s' '%s'", source_path, dest_path)
                              or string.format("cp '%s' '%s'", source_path, dest_path)
      local result = vim.fn.system(cmd)

      if vim.v.shell_error == 0 then
        table.insert(new_qf_list, {
          filename = dest_path,
          text = filename,
        })
        success_count = success_count + 1
      else
        vim.notify(string.format("Error %s %s: %s",
          move_files and "moving" or "copying", filename, result),
          vim.log.levels.ERROR)
      end
    end
  end

  -- Replace quickfix list with new entries
  if #new_qf_list > 0 then
    vim.fn.setqflist(new_qf_list, "r")
    vim.notify(string.format("%s %d file(s) to %s",
      move_files and "Moved" or "Copied", success_count, destination),
      vim.log.levels.INFO)
  end
end

-- Create user commands
vim.api.nvim_create_user_command('CopyQfFiles', function(opts)
  copy_qf_files_to_location({args = opts.args, move = false})
end, {nargs = 1, complete = 'dir'})

vim.api.nvim_create_user_command('MoveQfFiles', function(opts)
  copy_qf_files_to_location({args = opts.args, move = true})
end, {nargs = 1, complete = 'dir'})

