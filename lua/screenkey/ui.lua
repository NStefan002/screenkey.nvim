local api = vim.api
local config = require("screenkey.config")
local key_utils = require("screenkey.key_utils")
local log = require("screenkey.log")
local utils = require("screenkey.utils")

---@class screenkey.ui
---@field private active boolean
---@field private augrp integer
---@field private extm_id integer
local M = {}

---@return screenkey.ui
function M:new()
    local obj = {
        active = false,
        augrp = -1,
        extm_id = -1,
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

---@private
function M.set_highlights()
    for hl_grp, opts in pairs(config.options.hl_groups) do
        api.nvim_set_hl(vim.g.screenkey_ns_id, hl_grp, opts)
    end

    log:info("highlight groups are set")
end

---@private
function M:open_win()
    if vim.g.screenkey_bufnr == -1 or not api.nvim_buf_is_valid(vim.g.screenkey_bufnr) then
        vim.g.screenkey_bufnr = api.nvim_create_buf(false, true)
    end
    if vim.g.screenkey_winnr == -1 or not api.nvim_win_is_valid(vim.g.screenkey_winnr) then
        vim.g.screenkey_winnr =
            api.nvim_open_win(vim.g.screenkey_bufnr, false, config.options.win_opts)
    end
    if vim.g.screenkey_winnr == 0 then
        log:error("failed to create window")

        log:notify(vim.log.levels.ERROR, {
            { "Internal error: ", vim.log.levels.OFF },
            { " window failed to open ", vim.log.levels.ERROR },
        })
        return
    end
    self.active = true
    utils.clear_buf_lines(vim.g.screenkey_bufnr, 0, config.options.win_opts.height)
    api.nvim_set_option_value("filetype", "screenkey", { buf = vim.g.screenkey_bufnr })
    api.nvim_set_option_value("winfixbuf", true, { win = vim.g.screenkey_winnr })
    self.set_highlights()
    api.nvim_win_set_hl_ns(vim.g.screenkey_winnr, vim.g.screenkey_ns_id)

    log:debug(
        ("created window %d for buffer %d"):format(vim.g.screenkey_winnr, vim.g.screenkey_bufnr)
    )
end

-- TODO: maybe add logic to check if two windows (some other and screenkey) are overlapping

--- Set the zindex of the screenkey window to be +-1 of the target window (which contains target_bufnr)
---@private
---@param target_bufnr integer
---@param infront boolean if true move to front, else move to back
function M:update_zindex(target_bufnr, infront)
    if not self.active then
        return
    end

    local win_ids = api.nvim_tabpage_list_wins(0)
    local target_win_id = -1
    for _, win_id in ipairs(win_ids) do
        if api.nvim_win_get_buf(win_id) == target_bufnr then
            target_win_id = win_id
            break
        end
    end
    if target_win_id == -1 then
        return
    end
    local target_win_config = api.nvim_win_get_config(target_win_id)
    local target_zindex = target_win_config.zindex or 50
    api.nvim_win_set_config(
        vim.g.screenkey_winnr,
        { zindex = target_zindex + (infront and 1 or -1) }
    )

    log:debug(("target window (id: %d) zindex: %d"):format(target_win_id, target_zindex))
end

---@private
function M:create_autocmds()
    -- autocmds already set
    if self.augrp ~= -1 then
        return
    end

    self.augrp = api.nvim_create_augroup("screenkey.ui", {})

    local exiting = false
    api.nvim_create_autocmd({ "TabEnter", "WinClosed" }, {
        group = self.augrp,
        callback = function(ev)
            if
                self.active
                and not exiting
                and (ev.event == "TabEnter" or ev.match == tostring(vim.g.screenkey_winnr))
            then
                exiting = true
                vim.schedule(function()
                    M:redraw()
                    exiting = false
                end)

                log:debug("TabEnter/WinClosed: reopening window")
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
            self:update_zindex(ev.buf, infront)

            log:debug(("FileType %s: reopening window"):format(ev.match))
        end,
    })

    local old_width, old_height = vim.o.columns, vim.o.lines
    api.nvim_create_autocmd({ "VimResized" }, {
        group = self.augrp,
        pattern = "*",
        callback = function()
            log:debug("VimResized: resizing window")

            local new_width, new_height = vim.o.columns, vim.o.lines
            local width_ratio = new_width / old_width
            local height_ratio = new_height / old_height

            config.options.win_opts.col = utils.round(config.options.win_opts.col * width_ratio)
            config.options.win_opts.row = utils.round(config.options.win_opts.row * height_ratio)
            M:redraw()

            old_width, old_height = new_width, new_height
        end,
    })

    log:info("ui autocmds are set")
end

---@private
function M:close_win()
    if vim.g.screenkey_bufnr ~= -1 and api.nvim_buf_is_valid(vim.g.screenkey_bufnr) then
        api.nvim_buf_delete(vim.g.screenkey_bufnr, { force = true })

        log:debug(("closed buffer %d"):format(vim.g.screenkey_bufnr))
    end
    if vim.g.screenkey_winnr ~= -1 and api.nvim_win_is_valid(vim.g.screenkey_winnr) then
        api.nvim_win_close(vim.g.screenkey_winnr, true)

        log:debug(("closed window %d"):format(vim.g.screenkey_winnr))
    end
    vim.g.screenkey_winnr = -1
    vim.g.screenkey_bufnr = -1
    self.active = false
end

function M:toggle()
    log:trace("ui.toggle")

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
    log:trace("ui.redraw")

    if not self.active then
        return
    end
    self:close_win()
    self:open_win()
end

---@return boolean
function M:is_active()
    log:trace("ui.is_active")

    return self.active
end

---@param queued_keys screenkey.queued_key[]
function M:display_text(queued_keys)
    if not self.active then
        return
    end

    log:trace("ui.display_text")

    local colored_keys = key_utils.colorize_keys(queued_keys)
    log:trace("colored_keys:", colored_keys)

    colored_keys = config.options.colorize(colored_keys)
    log:trace("colored_keys after `colorize`:", colored_keys)

    local line = math.floor(config.options.win_opts.height / 2)
    -- center text inside of the screenkey window
    local col = math.floor(
        (config.options.win_opts.width - api.nvim_strwidth(key_utils.to_string(queued_keys))) / 2
    )
    vim.schedule(function()
        if not self.active then
            return
        end
        local extm_opts = self.extm_id == -1
                and { virt_text = colored_keys, virt_text_win_col = col }
            or { virt_text = colored_keys, virt_text_win_col = col, id = self.extm_id }
        log:trace(("%s extmarks"):format(self.extm_id == -1 and "set" or "update"))
        self.extm_id = api.nvim_buf_set_extmark(
            vim.g.screenkey_bufnr,
            vim.g.screenkey_ns_id,
            line,
            0,
            extm_opts
        )
    end)
end

return M:new()
