local api = vim.api
local Util = require("screenkey.util")

---@class ScreenkeyLogger
---@field lines string[]
---@field max_lines number
---@field enabled boolean
local ScreenkeyLogger = {}
ScreenkeyLogger.__index = ScreenkeyLogger

---@return ScreenkeyLogger
function ScreenkeyLogger.new()
    local self = {
        lines = {},
        max_lines = 50,
        enabled = false,
    }
    return setmetatable(self, ScreenkeyLogger)
end

function ScreenkeyLogger:disable()
    self.enabled = false
end

function ScreenkeyLogger:enable()
    self.enabled = true
end

---@param m integer
function ScreenkeyLogger:set_max_lines(m)
    self.max_lines = m
end

---@param ... any
function ScreenkeyLogger:log(...)
    if not self.enabled then
        return
    end

    local vararg = { ... }
    for _, v in ipairs(vararg) do
        local item = vim.inspect(v)
        local lines = Util.split(item, "\n")
        for _, line in ipairs(lines) do
            table.insert(self.lines, line)
        end
    end

    while #self.lines > self.max_lines do
        table.remove(self.lines, 1)
    end
end

function ScreenkeyLogger:clear()
    self.lines = {}
end

function ScreenkeyLogger:show()
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

return ScreenkeyLogger.new()
