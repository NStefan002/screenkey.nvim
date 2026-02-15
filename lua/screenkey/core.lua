local api = vim.api
local config = require("screenkey.config")
local key_utils = require("screenkey.key_utils")
local log = require("screenkey.log")
local ui = require("screenkey.ui")
local utils = require("screenkey.utils")

---@class screenkey.core
---@field private queued_keys screenkey.queued_key[]
---@field private statusline_component_active boolean
---@field private time integer
---@field private timer uv.uv_timer_t
local M = {}

---@return screenkey.core
function M:new()
    local obj = {
        queued_keys = {},
        statusline_component_active = false,
        time = 0,
        timer = nil,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---@private
function M.should_disable()
    local filetype = api.nvim_get_option_value("filetype", { buf = 0 })
    if utils.tbl_contains(config.options.disable.filetypes, filetype) then
        log:debug("disabling screenkey for filetype", filetype)
        return true
    end

    local buftype = api.nvim_get_option_value("buftype", { buf = 0 })
    if utils.tbl_contains(config.options.disable.buftypes, buftype) then
        log:debug("disabling screenkey for buftype", buftype)
        return true
    end

    local mode = api.nvim_get_mode().mode
    if utils.tbl_contains(config.options.disable.modes, mode) then
        log:debug("disabling screenkey for mode", mode)
        return true
    end

    return false
end

---@private
function M:create_timer()
    if config.options.clear_after <= 0 then
        return
    end
    self.timer = vim.uv.new_timer()
    self.timer:start(
        0,
        1000,
        vim.schedule_wrap(function()
            self.time = self.time + 1
            if self.time < config.options.clear_after then
                return
            end

            self.queued_keys = {}
            if ui:is_active() then
                log:debug("clearing screenkey buffer")
                utils.clear_buf_lines(vim.g.screenkey_bufnr, 0, config.options.win_opts.height)
            end
            if config.options.emit_events and self.statusline_component_active then
                log:debug("emitting ScreenkeyCleared event")
                api.nvim_exec_autocmds("User", { pattern = "ScreenkeyCleared" })
            end
        end)
    )
    log:info("created timer")
end

---@private
function M:kill_timer()
    if not self.timer then
        return
    end

    self.timer:stop()
    self.timer:close()
    self.timer = nil
    log:info("killed timer")
end

---@return fun(key: string, typed: string): string?
function M:on_key()
    log:trace("core.on_key")

    return function(key, typed)
        if not ui:is_active() and not self.statusline_component_active then
            self:kill_timer()
            return
        end
        if self.should_disable() then
            return
        end
        typed = typed or key
        log:trace("typed:", typed, "key:", key)
        if not typed or typed:len() == 0 then
            return
        end
        self.time = 0
        if not self.timer then
            self:create_timer()
        end
        local prev_str = key_utils.to_string(self.queued_keys)
        local transformed_keys = key_utils.transform_input(typed)
        self.queued_keys = key_utils.append_new_keys(self.queued_keys, transformed_keys)
        self.queued_keys = config.options.filter(self.queued_keys)
        self.queued_keys = key_utils.remove_extra_keys(self.queued_keys)
        local changed = key_utils.to_string(self.queued_keys) ~= prev_str
        if ui:is_active() then
            ui:display_text(self.queued_keys)
        end
        if changed and config.options.emit_events and self.statusline_component_active then
            log:trace("emitting ScreenkeyUpdated event")
            api.nvim_exec_autocmds("User", { pattern = "ScreenkeyUpdated" })
        end
    end
end

function M:toggle()
    log:trace("core.toggle")

    self.queued_keys = {}
    ui:toggle()
end

function M:redraw()
    log:trace("core.redraw")

    ui:redraw()
    ui:display_text(self.queued_keys)
end

function M:toggle_statusline_component()
    log:trace("core.toggle_statusline_component")

    self.statusline_component_active = not self.statusline_component_active
end

---@return boolean
function M:statusline_component_is_active()
    log:trace("core.statusline_component_is_active")

    return self.statusline_component_active
end

---@return string
function M:get_keys()
    log:trace("core.get_keys")

    return self.statusline_component_active and key_utils.to_string(self.queued_keys) or ""
end

return M:new()
