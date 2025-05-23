local api = vim.api
local utils = require("screenkey.utils")

---@class screenkey.log
---@field private levels table<integer, string>
---@field private highlights table<integer, string>
---@field private lines string[]
---@field private augrp integer
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
        augrp = -1,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---@private
function M:write()
    local filepath = require("screenkey.config").options.log.filepath
    local file, err = io.open(filepath, "a")
    if not file then
        self:notify(vim.log.levels.ERROR, {
            { "Error opening log file:\n", vim.log.levels.OFF },
            { err, vim.log.levels.ERROR },
        })
        self:error(("Error opening log file:\n%s"):format(err))
        return
    end
    file:write(table.concat(self.lines, "\n"))
    file:write("\n")
    file:close()
end

---@private
--- Returns lines if the file exists, otherwise returns nil and error message
---@return string[] | nil, string | nil
function M.read()
    local filepath = require("screenkey.config").options.log.filepath
    local file, err = io.open(filepath, "r")
    if not file then
        return nil, err
    end
    local lines = {}
    for line in file:lines() do
        table.insert(lines, line)
    end
    file:close()
    return lines, nil
end

---@private
function M:create_autocmds()
    -- autocmds already set
    if self.augrp ~= -1 then
        return
    end

    self.augrp = api.nvim_create_augroup("screenkey.log", {})
    api.nvim_create_autocmd("ExitPre", {
        group = self.augrp,
        callback = function()
            self:write()
        end,
        desc = "write screenkey log before neovim exits",
    })
end

---@private
---@param lvl integer
---@param ... any
function M:log(lvl, ...)
    self:create_autocmds()

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

    local lines, err = self.read()
    if not lines then
        lines = {}
        self:error(("Error while trying to read log file:\n%s"):format(err))
    end
    for _, line in ipairs(self.lines) do
        table.insert(lines, line)
    end
    -- reverse order so the latest log entries appear at the top of the buffer
    for i = 1, #lines / 2 do
        lines[i], lines[#lines - i + 1] = lines[#lines - i + 1], lines[i]
    end

    api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
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
