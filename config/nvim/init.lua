local theme_file = vim.fn.stdpath("config") .. "/theme_name.txt"
local f = io.open(theme_file, "r")
if f then
  local name = f:read("*all"):gsub("%s+", "")
  f:close()
  vim.g.lazyvim_colorscheme = name
end
require("config.lazy")
