local M = {}

-- Configure spell file download location
-- Set to use https://ftp.nluug.nl/vim/runtime/spell/ as the source
vim.opt.spellfile = vim.fn.stdpath("data") .. "/site/spell/custom.utf-8.add"

-- Set the spell file URL to the correct mirror
vim.g.spellfile_URL = "https://ftp.nluug.nl/vim/runtime/spell"

-- Languages to download
M.languages = { "en", "fr", "es", "de", "it", "ru" }

-- Check if all spell files exist
function M.check_spell_files_exist()
  local spell_dir = vim.fn.stdpath("data") .. "/site/spell"

  for _, lang in ipairs(M.languages) do
    local spl_file = spell_dir .. "/" .. lang .. ".utf-8.spl"
    if vim.fn.filereadable(spl_file) == 0 then
      return false
    end
  end

  return true
end

-- Download spell files for multiple languages
-- This will download spell files for: English, French, Spanish, German, Italian, Russian
function M.download_spell_files()
  local spell_dir = vim.fn.stdpath("data") .. "/site/spell"
  vim.fn.mkdir(spell_dir, "p")

  local base_url = "https://ftp.nluug.nl/vim/runtime/spell/"

  -- Check if curl is available
  local has_curl = vim.fn.executable("curl") == 1
  local has_wget = vim.fn.executable("wget") == 1

  if not has_curl and not has_wget then
    vim.notify("Neither curl nor wget found. Spell files will be downloaded by Neovim when needed.", vim.log.levels.WARN)
    return
  end

  for _, lang in ipairs(M.languages) do
    local spl_file = spell_dir .. "/" .. lang .. ".utf-8.spl"
    local sug_file = spell_dir .. "/" .. lang .. ".utf-8.sug"

    -- Download .spl file if it doesn't exist
    if vim.fn.filereadable(spl_file) == 0 then
      local spl_url = base_url .. lang .. ".utf-8.spl"
      local cmd
      if has_curl then
        cmd = string.format("curl -fsSL -o '%s' '%s'", spl_file, spl_url)
      else
        cmd = string.format("wget -q -O '%s' '%s'", spl_file, spl_url)
      end

      vim.notify("Downloading spell file for " .. lang .. "...", vim.log.levels.INFO)
      local result = vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        vim.notify("Failed to download spell file for " .. lang, vim.log.levels.WARN)
      else
        -- Validate download success (check file size > 0)
        local file_size = vim.fn.getfsize(spl_file)
        if file_size <= 0 then
          vim.notify("Downloaded spell file for " .. lang .. " appears to be empty", vim.log.levels.WARN)
          vim.fn.delete(spl_file)
        end
      end
    end

    -- Download .sug file if it doesn't exist
    if vim.fn.filereadable(sug_file) == 0 then
      local sug_url = base_url .. lang .. ".utf-8.sug"
      local cmd
      if has_curl then
        cmd = string.format("curl -fsSL -o '%s' '%s'", sug_file, sug_url)
      else
        cmd = string.format("wget -q -O '%s' '%s'", sug_file, sug_url)
      end

      vim.fn.system(cmd)
      -- Validate suggestions file (optional, but check if downloaded)
      if vim.v.shell_error == 0 then
        local file_size = vim.fn.getfsize(sug_file)
        if file_size <= 0 then
          vim.fn.delete(sug_file)
        end
      end
    end
  end
  vim.notify("Spell files download completed", vim.log.levels.INFO)
end

-- Check if spell files exist and conditionally download or disable plugins
function M.check_and_setup()
  if not M.check_spell_files_exist() then
    -- Spell files don't exist, download them
    vim.notify("Downloading missing spell files...", vim.log.levels.INFO)
    M.download_spell_files()
  else
    -- Spell files exist, disable netrw and spellfile_plugin
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    vim.g.loaded_spellfile_plugin = 1
  end
end

-- Setup function to be called from init
function M.setup()
  -- Check spell files early and conditionally disable plugins
  -- This runs before VimEnter to prevent netrw from loading
  M.check_and_setup()

  -- Setup autocmd for deferred checks
  local augroup = vim.api.nvim_create_augroup("SpellSetup", { clear = true })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    once = true,
    callback = function()
      -- Defer to avoid blocking startup
      vim.defer_fn(function()
        if not M.check_spell_files_exist() then
          vim.notify("Some spell files may be missing. Use :SpellDownload to download them.", vim.log.levels.WARN)
        end
      end, 1000)
    end
  })

  -- Create a user command to manually download spell files
  vim.api.nvim_create_user_command("SpellDownload", M.download_spell_files, {
    desc = "Download spell files for en, fr, es, de, it, ru"
  })

  -- Add spell toggle keybinding
  vim.keymap.set("n", "<leader>ts", function()
    vim.opt.spell = not vim.opt.spell:get()
    local status = vim.opt.spell:get() and "enabled" or "disabled"
    vim.notify("Spell check " .. status, vim.log.levels.INFO)
  end, { desc = "Toggle spell check" })
end

return M
