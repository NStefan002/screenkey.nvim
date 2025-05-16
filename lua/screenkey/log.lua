local api = vim.api
local utils = require("screenkey.utils")

---@class screenkey.log
---@field private levels table<integer, string>
---@field private highlights table<integer, string>
---@field private lines string[]
local M = {}

---@return screenkey.log
function M:new()
    local obj = {
        levels = {
            [vim.log.levels.TRACE] = "TRACE",
            [vim.log.levels.DEBUG] = "DEBUG",
            [vim.log.levels.INFO] = "INFO",
            [vim.log.levels.WARN] = "WARN",
            [vim.log.levels.ERROR] = "ERROR",
            [vim.log.levels.OFF] = "OFF",
        },
        highlights = {
            [vim.log.levels.TRACE] = "DiagnosticVirtualTextHint",
            [vim.log.levels.DEBUG] = "DiagnosticVirtualTextOk",
            [vim.log.levels.INFO] = "DiagnosticVirtualTextInfo",
            [vim.log.levels.WARN] = "DiagnosticVirtualTextWarn",
            [vim.log.levels.ERROR] = "DiagnosticVirtualTextError",
            [vim.log.levels.OFF] = "Normal",
        },
        lines = {},
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---@private
---@param lvl integer
---@param ... any
function M:log(lvl, ...)
    local config = require("screenkey.config")

    if config.options.log.min_level > lvl then
        return
    end

    local vararg = { ... }
    local prefix = ("%s [%s]"):format(os.date("%H:%M:%S"), self.levels[lvl])
    table.insert(self.lines, prefix)
    for _, v in ipairs(vararg) do
        local item = vim.inspect(v)
        local lines = utils.split(item, "\n")
        for _, line in ipairs(lines) do
            table.insert(self.lines, line)
        end
    end
end

---@param lvl vim.log.levels
---@param msg screenkey.notification_message[]
function M:notify(lvl, msg)
    local config = require("screenkey.config")

    if config.options.notify_method == "none" then
        return
    end

    -- "echo" method

    if config.options.notify_method == "echo" then
        table.insert(msg, 1, { " screenkey.nvim ", lvl })
        table.insert(msg, 2, { " ", vim.log.levels.OFF })
        api.nvim_echo(
            vim.iter(msg)
                :map(function(p)
                    return { p[1], self.highlights[p[2]] or "" }
                end)
                :totable(),
            true,
            { verbose = false }
        )
        return
    end

    -- "notify" method

    local text = table.concat(
        vim.iter(msg)
            :map(function(p)
                return p[1]
            end)
            :totable(),
        " "
    )

    vim.notify(text, lvl, { title = "screenkey.nvim" })
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

function M:trace(...)
    self:log(vim.log.levels.TRACE, ...)
end

function M:debug(...)
    self:log(vim.log.levels.DEBUG, ...)
end

function M:info(...)
    self:log(vim.log.levels.INFO, ...)
end

function M:warn(...)
    self:log(vim.log.levels.WARN, ...)
end

function M:error(...)
    self:log(vim.log.levels.ERROR, ...)
end

return M:new()
