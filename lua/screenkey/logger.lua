local api = vim.api
local utils = require("screenkey.utils")

---@class ScreenkeyLogger
---@field lines string[]
---@field max_lines number
---@field enabled boolean
local M = {}

---@return ScreenkeyLogger
function M:new()
    local obj = {
        lines = {},
        max_lines = 50,
        enabled = false,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function M:disable()
    self.enabled = false
end

function M:enable()
    self.enabled = true
end

---@param m integer
function M:set_max_lines(m)
    self.max_lines = m
end

---@param ... any
function M:log(...)
    if not self.enabled then
        return
    end

    local vararg = { ... }
    for _, v in ipairs(vararg) do
        local item = vim.inspect(v)
        local lines = utils.split(item, "\n")
        for _, line in ipairs(lines) do
            table.insert(self.lines, line)
        end
    end

    while #self.lines > self.max_lines do
        table.remove(self.lines, 1)
    end
end

function M:clear()
    self.lines = {}
end

function M:show()
    local bufnr = api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns / 2)
    local height = math.floor((vim.o.lines - vim.o.cmdheight) / 2)
    local winnr = api.nvim_open_win(bufnr, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = require("screenkey.config").options.win_opts.border,
        noautocmd = true,
    })
    if winnr == 0 then
        return
    end
    api.nvim_set_option_value("filetype", "screenkey_log", { buf = bufnr })
    api.nvim_buf_set_lines(bufnr, 0, -1, false, self.lines)
end

return M:new()
