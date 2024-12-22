require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = "both" -- to enable cursorline!
o.encoding = "utf-8"
o.clipboard = "unnamedplus"
-- Prevent issues with some language servers
o.backup = false
o.swapfile = false
o.scrolloff = 20
o.termguicolors = true
o.emoji = false
o.tabstop = 2
o.ignorecase = true
o.lazyredraw = false
o.autoindent = true

local g = vim.g
g.bookmark_sign = ""
g.tabufline_visible = true
g.showtabline = 1
g.dap_virtual_text = true
