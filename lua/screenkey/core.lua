local api = vim.api
local config = require("screenkey.config")
local key_utils = require("screenkey.key_utils")
local log = require("screenkey.logger")
local ui = require("screenkey.ui")
local utils = require("screenkey.utils")

---@class screenkey.core
---@field private queued_keys screenkey.queued_key[]
---@field private time integer
---@field private timer uv_timer_t
local M = {}

---@return screenkey.core
function M:new()
    local obj = {
        queued_keys = {},
        time = 0,
        timer = nil,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---@private
function M:create_timer()
    self.timer = vim.uv.new_timer()
    self.timer:start(
        0,
        1000,
        vim.schedule_wrap(function()
            self.time = self.time + 1
            if self.time >= config.options.clear_after then
                self.queued_keys = {}
                if ui:is_active() then
                    utils.clear_buf_lines(vim.g.screenkey_bufnr, 0, config.options.win_opts.height)
                end
                if not config.options.disable.events and vim.g.screenkey_statusline_component then
                    api.nvim_exec_autocmds("User", { pattern = "ScreenkeyCleared" })
                end
            end
        end)
    )
    log:log("created timer")
end

---@private
function M:kill_timer()
    if self.timer then
        self.timer:stop()
        self.timer:close()
        self.timer = nil
        log:log("killed timer")
    end
end

---@return fun(key: string, typed: string): string?
function M:on_key()
    return function(key, typed)
        if not ui:is_active() and not vim.g.screenkey_statusline_component then
            self:kill_timer()
            return
        end
        if utils.should_disable() then
            return
        end
        typed = typed or key
        if not typed or #typed == 0 then
            return
        end
        self.time = 0
        if not self.timer then
            self:create_timer()
        end
        local transformed_keys = key_utils.transform_input(typed)
        for _, k in pairs(transformed_keys) do
            table.insert(self.queued_keys, k)
        end
        if ui:is_active() then
            self.queued_keys = config.options.filter(self.queued_keys)
            ui:display_text(self.queued_keys)
        end
        if not config.options.disable.events and vim.g.screenkey_statusline_component then
            api.nvim_exec_autocmds("User", { pattern = "ScreenkeyUpdated" })
        end
    end
end

function M:toggle()
    self.queued_keys = {}
    ui:toggle()
end

function M:redraw()
    ui:redraw()
    ui:display_text(self.queued_keys)
end

---@return string
function M:get_keys()
    return vim.g.screenkey_statusline_component and key_utils.compress_output(self.queued_keys)
        or ""
end

return M:new()
