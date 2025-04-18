local api = vim.api
local config = require("screenkey.config")
local key_utils = require("screenkey.key_utils")
local log = require("screenkey.logger")
local utils = require("screenkey.utils")

---@class screenkey.ui
---@field private active boolean
---@field private augrp integer
local M = {}

---@return screenkey.ui
function M:new()
    local obj = {
        active = false,
        augrp = -1,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---@private
function M.open_win()
    if vim.g.screenkey_bufnr == -1 or not api.nvim_buf_is_valid(vim.g.screenkey_bufnr) then
        vim.g.screenkey_bufnr = api.nvim_create_buf(false, true)
    end
    if vim.g.screenkey_winnr == -1 or not api.nvim_win_is_valid(vim.g.screenkey_winnr) then
        vim.g.screenkey_winnr =
            api.nvim_open_win(vim.g.screenkey_bufnr, false, config.options.win_opts)
    end
    if vim.g.screenkey_winnr == 0 then
        log:log("failed to create window")
        error("Screenkey: failed to create window")
    end
    api.nvim_set_option_value("filetype", "screenkey", { buf = vim.g.screenkey_bufnr })
    log:log(
        ("created window %d for buffer %d"):format(vim.g.screenkey_winnr, vim.g.screenkey_bufnr)
    )
end

function M:create_autocmds()
    -- autocmds already set
    if self.augrp ~= -1 then
        return
    end

    self.augrp = api.nvim_create_augroup("Screenkey", {})

    local exiting = false
    api.nvim_create_autocmd({ "TabEnter", "WinClosed" }, {
        group = self.augrp,
        callback = function(ev)
            if
                self.active
                and not exiting
                and (ev.event == "TabEnter" or ev.match == tostring(vim.g.screenkey_winnr))
            then
                log:log("TabEnter/WinClosed: reopening window")
                exiting = true
                vim.schedule(function()
                    M:redraw()
                    exiting = false
                end)
            end
        end,
        desc = "make the Screenkey window persistent",
    })

    api.nvim_create_autocmd({ "FileType" }, {
        group = self.augrp,
        pattern = "*",
        callback = function(ev)
            ---@param tx string
            ---@param v string
            ---@return boolean
            local function cmp(tx, v)
                return v:match(tx) ~= nil
            end
            local infront = utils.tbl_contains(config.options.display_infront, ev.match, cmp)
            local behind = utils.tbl_contains(config.options.display_behind, ev.match, cmp)
            -- NOTE: I don't want to deal with conflicts (for now)
            if (infront and behind) or (not infront and not behind) then
                return
            end
            log:log(("FileType %s: reopening window"):format(ev.match))
            utils.update_zindex(ev.buf, infront)
            M:redraw()
        end,
    })
    -- TODO: do this instead of the previous one (currently doesn't work, don't know why)
    -- api.nvim_create_autocmd({ "WinNew", "BufWinEnter" }, {
    --     group = augrp,
    --     pattern = "*",
    --     callback = function(ev)
    --         P(ev.event)
    --     end,
    -- })

    local old_width, old_height = vim.o.columns, vim.o.lines
    api.nvim_create_autocmd({ "VimResized" }, {
        group = self.augrp,
        pattern = "*",
        callback = function()
            local new_width, new_height = vim.o.columns, vim.o.lines
            local width_ratio = new_width / old_width
            local height_ratio = new_height / old_height

            config.options.win_opts.col = utils.round(config.options.win_opts.col * width_ratio)
            config.options.win_opts.row = utils.round(config.options.win_opts.row * height_ratio)
            M:redraw()

            old_width, old_height = new_width, new_height
        end,
    })
end

---@private
function M.close_win()
    if vim.g.screenkey_bufnr ~= -1 and api.nvim_buf_is_valid(vim.g.screenkey_bufnr) then
        api.nvim_buf_delete(vim.g.screenkey_bufnr, { force = true })
    end
    if vim.g.screenkey_winnr ~= -1 and api.nvim_win_is_valid(vim.g.screenkey_winnr) then
        api.nvim_win_close(vim.g.screenkey_winnr, true)
    end
    log:log(("closed window %d and buffer %d"):format(vim.g.screenkey_winnr, vim.g.screenkey_bufnr))
    vim.g.screenkey_winnr = -1
    vim.g.screenkey_bufnr = -1
end

function M:toggle()
    self.active = not self.active
    self.queued_keys = {}
    if self.active then
        self:open_win()
        self:create_autocmds()
    else
        self:close_win()
    end
end

function M:redraw()
    if not self.active then
        return
    end
    self:close_win()
    self:open_win()
end

---@return boolean
function M:is_active()
    return self.active
end

---@param queued_keys screenkey.queued_key[]
function M:display_text(queued_keys)
    if not self.active then
        return
    end

    local text = key_utils.compress_output(queued_keys)
    -- center text inside of screenkey window
    local padding =
        string.rep(" ", math.floor((config.options.win_opts.width - api.nvim_strwidth(text)) / 2))
    local line = math.floor(config.options.win_opts.height / 2)
    vim.schedule(function()
        if not self.active then
            return
        end
        api.nvim_buf_set_lines(
            vim.g.screenkey_bufnr,
            line,
            line + 1,
            false,
            { string.format("%s%s", padding, text) }
        )
    end)
end

return M:new()
