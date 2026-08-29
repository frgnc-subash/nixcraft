local name_file = vim.fn.stdpath("config") .. "/theme_name.txt"

local function read_theme_name()
  local f = io.open(name_file, "r")
  if not f then
    return nil
  end

  local name = f:read("*all"):gsub("%s+", "")
  f:close()

  if name == "" then
    return nil
  end

  return name
end

local function apply_theme()
  local name = read_theme_name()
  if not name then
    return
  end

  vim.schedule(function()
    pcall(vim.cmd.colorscheme, name)
  end)
end

local function watch_file(path, callback)
  local w = vim.uv.new_fs_event()
  local on_change
  on_change = function(err, filename, events)
    if err then
      return
    end
    -- Reload the theme
    callback()
    -- Keep watching
    w:start(path, {}, on_change)
  end
  w:start(path, {}, on_change)
end

-- Apply on startup
apply_theme()

-- Watch files
watch_file(name_file, apply_theme)
