local M = {}

-- Function to run the zoekt search
function M.search(query)
  -- Build the command to run zoekt
  local command = "zoekt " .. query

  -- Run the command asynchronously
  vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      M.handle_results(data)
    end,
    on_stderr = function(_, data)
      print("Error for " .. command .. "\nMSG:" .. table.concat(data, "\n"))
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        print("Search failed with exit code: " .. code)
      end
    end,
  })
end

-- Function to handle the results from zoekt
function M.handle_results(data)
  local results = {}
  for _, line in ipairs(data) do
    -- Assuming each line is formatted as "filename:line_number:line_content"
    local filename, line_number, content = line:match("^(.*):(.*):(.*)$")
    if filename and line_number and content then
      table.insert(results, {
        filename = filename,
        lnum = tonumber(line_number),
        col = 1,
        text = content,
      })
    end
  end

  -- Populate the quickfix list with results
  if #results > 0 then
    vim.fn.setqflist({}, ' ', { title = 'Zoekt Results', items = results })
    vim.cmd('Telescope quickfix theme=dropdown') -- Open the quickfix window
  else
    print("No results found.")
  end
end

-- find references to this word
function M.find_references()
  local word = vim.fn.expand('<cword>')
  if word == '' then
    print("No word under cursor.")
    return
  end

  -- Build the command to run zoekt
  local command = "zoekt " ..
      "-index_dir ./.zoekt \\\\b" .. word .. "\\\\b" .. " lang:" .. vim.bo.filetype .. " case:yes"

  -- Run the command asynchronously
  vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      M.handle_results(data)
    end,
    on_stderr = function(_, data)
      print("Error for " .. command .. "\nMSG:" .. table.concat(data, "\n"))
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        print("Search failed with exit code: " .. code)
      end
    end,
  })
  -- Trigger zoekt search for the word under the cursor
  print("\\b" .. word .. "\\b" .. " lang:" .. vim.bo.filetype .. " case:yes")
end

-- find references to this word
function M.find_definitions()
  local word = vim.fn.expand('<cword>')
  if word == '' then
    print("No word under cursor.")
    return
  end

  -- Build the command to run zoekt
  local command = "zoekt " .. "-index_dir ./.zoekt sym:\\\\b" .. word .. "\\\\b" .. " lang:" .. vim.bo.filetype

  -- Run the command asynchronously
  vim.fn.jobstart(command, {
    on_stdout = function(_, data)
      M.handle_results(data)
    end,
    on_stderr = function(_, data)
      print("Error for " .. command .. "\nMSG:" .. table.concat(data, "\n"))
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        print("Search failed with exit code: " .. code)
      end
    end,
  })
end

-- Command to trigger the search
function M.setup()
  vim.api.nvim_create_user_command('Zoekt', function(opts)
    M.search(opts.args)
  end, { nargs = 0 })

  vim.api.nvim_create_user_command('ZoektRef', function()
    M.find_references()
  end, { nargs = 0 })

  vim.api.nvim_create_user_command('ZoektDef', function()
    M.find_references()
  end, { nargs = 0 })
end

return M
