local M = {}
local api = vim.api
local Util = require("screenkey.util")
local Config = require("screenkey.config")
local Log = require("screenkey.logger")

local active = false
local bufnr, winnr = -1, -1
local ns_id = api.nvim_create_namespace("screenkey")
local grp = -1
---@type screenkey.queued_key[]
local queued_keys = {}
local time = 0 -- time in seconds
local timer = nil

local function create_window()
    if bufnr == -1 or not api.nvim_buf_is_valid(bufnr) then
        bufnr = api.nvim_create_buf(false, true)
    end
    winnr = api.nvim_open_win(bufnr, false, Config.options.win_opts)

    if winnr == 0 then
        Log:log("failed to create window")
        error("Screenkey: failed to create window")
    end

    api.nvim_set_option_value("filetype", "screenkey", { buf = bufnr })
end

local function close_window()
    if bufnr ~= -1 and api.nvim_buf_is_valid(bufnr) then
        api.nvim_buf_delete(bufnr, { force = true })
    end

    if winnr ~= -1 and api.nvim_win_is_valid(winnr) then
        api.nvim_win_close(winnr, true)
    end

    bufnr, winnr = -1, -1
end

local function clear_screenkey_buffer()
    local rep = {}
    for _ = 1, Config.options.win_opts.height do
        table.insert(rep, "")
    end
    api.nvim_buf_set_lines(bufnr, 0, -1, false, rep)
end

local function create_timer()
    timer = vim.uv.new_timer()
    timer:start(
        0,
        1000,
        vim.schedule_wrap(function()
            time = time + 1
            if time >= Config.options.clear_after then
                queued_keys = {}
                if active then
                    clear_screenkey_buffer()
                end
                if not Config.options.disable.events and vim.g.screenkey_statusline_component then
                    vim.api.nvim_exec_autocmds("User", { pattern = "ScreenkeyCleared" })
                end
            end
        end)
    )
end

local function kill_timer()
    if timer then
        timer:stop()
        timer:close()
        timer = nil
    end
end

--- Explanation:
--- Vim sometimes packs multiple keys into one input, e.g. `jk` when exiting insert mode with `jk`.
--- For this reason, we need to split the input into individual keys and transform them into the
--- corresponding symbols.
--- see `:h keytrans()`
---@param in_key string
---@return screenkey.queued_key[]
local function transform_input(in_key)
    in_key = vim.fn.keytrans(in_key)
    local is_mapping = Util.is_mapping(in_key)
    local split = api.nvim_strwidth(in_key) > 1 and Util.split_key(in_key) or { in_key }
    if Util.which_key_loaded() and #split > 1 then
        queued_keys = Util.remove_which_key_extra_keys(queued_keys, split)
    end
    ---@type screenkey.queued_key[]
    local transformed_keys = {}

    for _, k in pairs(split) do
        -- ignore mouse input (just use keyboard)
        if
            not (
                k:match("Mouse") ~= nil
                or k:match("Release") ~= nil
                or k:match("Middle") ~= nil
                or k:match("Scroll") ~= nil
            )
        then
            local leader = vim.g.mapleader or ""
            if
                Config.options.show_leader
                and is_mapping
                and (k:upper() == leader:upper() or k:upper() == vim.fn.keytrans(leader):upper())
            then
                table.insert(
                    transformed_keys,
                    { key = Config.options.keys["<leader>"], is_mapping = true }
                )
            elseif Util.is_special_key(k) then
                local modifier = k:match("^<([CMAD])%-.+>$")
                local key = k:match("^<.-%-.*(.)>$")
                local shift = k:match("^<.-%-(S)%-.>$") ~= nil

                if key ~= nil then
                    if not shift then
                        key = key:lower()
                    end
                    if modifier == "C" then
                        table.insert(transformed_keys, {
                            key = string.format("%s+%s", Config.options.keys["CTRL"], key),
                            is_mapping = is_mapping,
                        })
                    elseif modifier == "A" or modifier == "M" then
                        table.insert(transformed_keys, {
                            key = string.format("%s+%s", Config.options.keys["ALT"], key),
                            is_mapping = is_mapping,
                        })
                    elseif modifier == "D" then
                        table.insert(transformed_keys, {
                            key = string.format("%s+%s", Config.options.keys["SUPER"], key),
                            is_mapping = is_mapping,
                        })
                    end
                end
            else
                table.insert(
                    transformed_keys,
                    { key = Config.options.keys[k:upper()] or k, is_mapping = is_mapping }
                )
            end
        end
    end

    if Config.options.group_mappings and #transformed_keys > 0 and is_mapping then
        return {
            {
                key = table.concat(
                    vim.tbl_map(function(k)
                        return k.key
                    end, transformed_keys),
                    ""
                ),
                is_mapping = true,
            },
        }
    else
        return transformed_keys
    end
end

---@return string
local function compress_output()
    local compressed_keys = {}

    local last_key = queued_keys[1] and queued_keys[1].key or ""

    local duplicates = 0
    for _, queued_key in ipairs(queued_keys) do
        local key = queued_key.key
        if key == last_key then
            duplicates = duplicates + 1
        else
            if duplicates >= Config.options.compress_after then
                table.insert(compressed_keys, string.format("%s..x%d", last_key, duplicates))
            else
                for _ = 1, duplicates do
                    table.insert(compressed_keys, last_key)
                end
            end
            last_key = key
            duplicates = 1
        end
    end
    -- check the last key
    if duplicates >= Config.options.compress_after then
        table.insert(compressed_keys, string.format("%s..x%d", last_key, duplicates))
    else
        for _ = 1, duplicates do
            table.insert(compressed_keys, last_key)
        end
    end

    -- remove old entries
    local text = table.concat(compressed_keys, Config.options.separator)
    while api.nvim_strwidth(text) > Config.options.win_opts.width - 2 do
        local removed = table.remove(compressed_keys, 1)
        -- HACK: don't touch this, please
        local num_removed = tonumber(string.match(removed:match("%.%.x%d$") or "1", "%d$"))
        for _ = 1, num_removed do
            table.remove(queued_keys, 1)
        end
        text = table.concat(compressed_keys, Config.options.separator)
    end

    return text
end

local function display_text()
    local text = compress_output()
    -- center text inside of screenkey window
    local padding =
        string.rep(" ", math.floor((Config.options.win_opts.width - api.nvim_strwidth(text)) / 2))
    local line = math.floor(Config.options.win_opts.height / 2)
    vim.schedule(function()
        if not active then
            return
        end
        api.nvim_buf_set_lines(
            bufnr,
            line,
            line + 1,
            false,
            { string.format("%s%s", padding, text) }
        )
    end)
end

local function create_autocmds()
    -- autocmds already set
    if grp ~= -1 then
        return
    end

    grp = api.nvim_create_augroup("Screenkey", {})

    local exiting = false
    api.nvim_create_autocmd({ "TabEnter", "WinClosed" }, {
        group = grp,
        callback = function(ev)
            if
                active
                and not exiting
                and (ev.event == "TabEnter" or ev.match == tostring(winnr))
            then
                Log:log("TabEnter/WinClosed: reopening window")
                exiting = true
                vim.schedule(function()
                    M.redraw()
                    exiting = false
                end)
            end
        end,
        desc = "make the Screenkey window persistent",
    })

    api.nvim_create_autocmd({ "FileType" }, {
        group = grp,
        pattern = "*",
        callback = function(ev)
            ---@param tx string
            ---@param v string
            ---@return boolean
            local function cmp(tx, v)
                return v:match(tx) ~= nil
            end
            local infront = Util.tbl_contains(Config.options.display_infront, ev.match, cmp)
            local behind = Util.tbl_contains(Config.options.display_behind, ev.match, cmp)
            -- NOTE: I don't want to deal with conflicts (for now)
            if (infront and behind) or (not infront and not behind) then
                return
            end
            Log:log(("FileType %s: reopening window"):format(ev.match))
            Util.update_zindex(ev.buf, infront)
            M.redraw()
        end,
    })
    -- TODO: do this instead of the previous one (currently doesn't work, don't know why)
    -- api.nvim_create_autocmd({ "WinNew", "BufWinEnter" }, {
    --     group = grp,
    --     pattern = "*",
    --     callback = function(ev)
    --         P(ev.event)
    --     end,
    -- })

    local old_width, old_height = vim.o.columns, vim.o.lines
    api.nvim_create_autocmd({ "VimResized" }, {
        group = grp,
        pattern = "*",
        callback = function()
            local new_width, new_height = vim.o.columns, vim.o.lines
            local width_ratio = new_width / old_width
            local height_ratio = new_height / old_height

            Config.options.win_opts.col = Util.round(Config.options.win_opts.col * width_ratio)
            Config.options.win_opts.row = Util.round(Config.options.win_opts.row * height_ratio)
            M.redraw()

            old_width, old_height = new_width, new_height
        end,
    })
end

vim.on_key(function(key, typed)
    local statusline_enabled = vim.g.screenkey_statusline_component
    if not active and not statusline_enabled then
        kill_timer()
        return
    end
    if Util.should_disable() then
        return
    end
    typed = typed or key
    if not typed or #typed == 0 then
        return
    end
    time = 0
    if not timer then
        create_timer()
    end
    local transformed_keys = transform_input(typed)
    for _, k in pairs(transformed_keys) do
        table.insert(queued_keys, k)
    end
    if active then
        queued_keys = Config.options.filter(queued_keys)
        display_text()
    end
    if not Config.options.disable.events and statusline_enabled then
        vim.api.nvim_exec_autocmds("User", { pattern = "ScreenkeyUpdated" })
    end
end, ns_id)

---@param opts? screenkey.config.partial
function M.setup(opts)
    Config.setup(opts)
end

function M.toggle()
    active = not active
    queued_keys = {}
    if active then
        create_window()
        create_autocmds()
    else
        close_window()
    end
end

function M.redraw()
    if not active then
        return
    end
    close_window()
    create_window()
    display_text()
end

---@return string
function M.get_keys()
    return vim.g.screenkey_statusline_component and compress_output() or ""
end

---@return boolean
function M.is_active()
    return active
end

return M
