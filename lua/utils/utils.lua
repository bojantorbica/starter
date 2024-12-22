---@class Utils
--- Check if any value is a table
---@field is_tbl fun(v: any): boolean
--- Create a global keymap
---@field glb_map fun(mode: string | table, lhs: string | table, rhs: string | fun(), opts?: table | nil)
--- Create a keymap local to buffer
---@field buf_map fun(buf?: integer, mode: string | table, lhs: string | table, rhs: string | fun(), opts?: table)

local M = {}


M.is_tbl = function(v)
  if type(v) == "table" then
    return true
  else
    return false
  end
end

M.glb_map = function(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }

  if opts then
    options = vim.tbl_extend("force", options, opts)
  end

  if M.is_tbl(lhs) then
    ---@cast lhs table
    for _, trigger in ipairs(lhs) do
      vim.keymap.set(mode, trigger, rhs, options)
    end
  else
    ---@cast lhs string
    vim.keymap.set(mode, lhs, rhs, options)
  end
end

M.buf_map = function(bufnr, mode, lhs, rhs, opts)
  opts = opts or {}
  opts.buffer = bufnr and bufnr or 0
  M.glb_map(mode, lhs, rhs, opts)
end

return M
