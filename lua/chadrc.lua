-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  transparency = true,
  theme = "catppuccin",
  integrations = {
    "blankline",
    "cmp",
    "codeactionmenu",
    "dap",
    "devicons",
    "hop",
    "lsp",
    "markview",
    "mason",
    "neogit",
    "notify",
    "nvimtree",
  },
}

M.base46.hl_override = {
  DevIconMd = { fg = "#FFFFFF", bg = "NONE" },
  FloatTitle = { link = "FloatBorder" },
  CursorLine = { bg = "black2" },
  CursorLineNr = { bold = true },
  CmpBorder = { link = "FloatBorder" },
  CmpDocBorder = { link = "FloatBorder" },
  TelescopeBorder = { link = "FloatBorder" },
  TelescopePromptBorder = { link = "FloatBorder" },
  NeogitDiffContext = { bg = "#171B21" },
  NeogitDiffContextCursor = { bg = "black2" },
  NeogitDiffContextHighlight = { link = "NeogitDiffContext" },
  TbBufOffModified = { fg = { "green", "black", 50 } },
  FoldColumn = { link = "FloatBorder" },
  Comment = { italic = true },
  ["@comment"] = { link = "Comment" },
  ["@keyword"] = { italic = true },
  ["@markup.heading"] = { fg = "NONE", bg = "NONE" },
}

M.ui = {
  cmp = {
    style = "default",
  },
  statusline = {
    theme = "vscode_colored",
    separator_style = "default",
    order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "diagnostics", "lsp", "cursor", "cwd" },
    modules = {
      file = function()
        local transparency = M.base46.transparency
        local hl = ""
        local icon = " 󰈚 "
        local path = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0))
        local name = (path == "" and "Empty") or vim.fs.basename(path)
        local ext = name:match "%.([^%.]+)$" or name

        if name ~= "Empty" then
          local devicons_present, devicons = pcall(require, "nvim-web-devicons")
          if devicons_present then
            local hl_group = "DevIcon" .. ext
            local ok, ft_hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group })
            if ok and ft_hl.fg then
              local ft_fg = string.format("#%06x", ft_hl.fg)
              local st_hl_name = "St_DevIcon" .. ext
              hl = "%#" .. st_hl_name .. "#"
              vim.api.nvim_set_hl(0, st_hl_name, { bg = transparency and "NONE" or "#242D3D", fg = ft_fg })
              local ft_icon = devicons.get_icon(name)
              icon = (ft_icon ~= nil and " " .. ft_icon .. " ") or (" " .. icon .. " ")
            else
              return
            end
          end
        end

        return "%#StText#" .. " " .. hl .. name .. icon .. "%#StText#"
      end,
      lsp = function()
        local count = 0
        local display = ""
        local run = "%@LspHealthCheck@"
        local stop = "%X"

        if rawget(vim, "lsp") then
          for a, client in ipairs(vim.lsp.get_clients()) do
            if client.attached_buffers[vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)] then
              count = count + 1
              display = (vim.o.columns > 100 and run .. " %#St_Lsp#  LSP ~ " .. client.name .. " " .. stop)
                or run .. " %#St_Lsp#  LSP " .. stop
            end
          end
        end

        if count > 1 then
          return run .. " %#St_Lsp#  LSP (" .. count .. ") " .. stop
        else
          return display
        end
      end,
      git = function()
        local run = "%@RunNeogit@"
        local stop = "%X"

        local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid or 0)
        if not vim.b[bufnr].gitsigns_head or vim.b[bufnr].gitsigns_git_status then
          return ""
        end

        local git_status = vim.b[bufnr].gitsigns_status_dict
        local clear_hl = "%#StText#"
        local add_hl = "%#St_Lsp#"
        local changed_hl = "%#StText#"
        local rm_hl = "%#St_LspError#"
        local branch_hl = "%#St_GitBranch#"

        local added = (git_status.added and git_status.added ~= 0)
            and (add_hl .. "  " .. clear_hl .. git_status.added)
          or ""
        local changed = (git_status.changed and git_status.changed ~= 0)
            and (changed_hl .. "  " .. clear_hl .. git_status.changed)
          or ""
        local removed = (git_status.removed and git_status.removed ~= 0)
            and (rm_hl .. "  " .. clear_hl .. git_status.removed)
          or ""
        local branch_name = branch_hl .. " " .. clear_hl .. git_status.head

        return run .. " " .. branch_name .. " " .. added .. changed .. removed .. stop
      end,
    },
  },
}

M.colorify = {
  enabled = true,
  mode = "virtual",
  virt_text = "󱓻 ",
  highlight = { hex = true, lspvars = true },
}

M.lsp = {
  signature = false,
}

M.term = {
  float = {
    border = "rounded",
    height = 0.5,
    width = 0.58,
    col = 0.2,
    row = 0.2,
  },
  sizes = {},
}

return M
