local M = {}
local api = vim.api
local Util = require("screenkey.util")
local Config = require("screenkey.config")

local active = false
local bufnr, winnr = -1, -1
local ns_id = api.nvim_create_namespace("screenkey")
local grp = -1
local queued_keys = {}
local time = 0 -- time in seconds
local timer = nil

local function create_window()
    if bufnr == -1 or not vim.api.nvim_buf_is_valid(bufnr) then
        bufnr = api.nvim_create_buf(false, true)
    end
    winnr = api.nvim_open_win(
        bufnr,
        false,
        vim.tbl_deep_extend("keep", {
            title = "Screenkey",
            title_pos = "center",
            style = "minimal",
            focusable = false,
            noautocmd = true,
        }, Config.options.win_opts)
    )

    if winnr == 0 then
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

local function create_timer()
    timer = vim.uv.new_timer()
    timer:start(
        0,
        1000,
        vim.schedule_wrap(function()
            time = time + 1
            if time == Config.options.clear_after then
                queued_keys = {}
                local rep = {}
                for _ = 1, Config.options.win_opts.height do
                    table.insert(rep, "")
                end
                api.nvim_buf_set_lines(bufnr, 0, -1, false, rep)
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
---@return string[]
local function transform_input(in_key)
    in_key = vim.fn.keytrans(in_key)
    local split = Util.split_key(in_key)
    ---@type string[]
    local transformed_keys = {}

    for _, k in pairs(split) do
        -- ignore mouse input (just use keyboard)
        if not (k:match("Left") or k:match("Right") or k:match("Middle") or k:match("Scroll")) then
            local leader = vim.g.mapleader or ""
            if
                Config.options.show_leader
                and Util.is_mapping(in_key)
                and (k:upper() == leader:upper() or k:upper() == vim.fn.keytrans(leader):upper())
            then
                table.insert(transformed_keys, "<leader>")
            elseif #k == 1 then
                table.insert(transformed_keys, k)
            elseif Config.options.keys[k:upper()] then
                table.insert(transformed_keys, Config.options.keys[k:upper()])
            else
                local modifier = k:match("^<([CMAD])%-.+>$")
                local key = k:match("^<.-%-.*(.)>$")
                local shift = k:match("^<.-%-(S)%-.>$") ~= nil

                if key ~= nil then
                    if not shift then
                        key = key:lower()
                    end
                    if modifier == "C" then
                        table.insert(
                            transformed_keys,
                            string.format("%s+%s", Config.options.keys["CTRL"], key)
                        )
                    elseif modifier == "A" or modifier == "M" then
                        table.insert(
                            transformed_keys,
                            string.format("%s+%s", Config.options.keys["ALT"], key)
                        )
                    elseif modifier == "D" then
                        table.insert(
                            transformed_keys,
                            string.format("%s+%s", Config.options.keys["SUPER"], key)
                        )
                    end
                end
            end
        end
    end

    if Config.options.group_mappings then
        return { table.concat(transformed_keys, "") }
    else
        return transformed_keys
    end
end

---@return string
local function compress_output()
    local compressed_keys = {}

    local last_key = queued_keys[1]
    local duplicates = 0
    for _, key in ipairs(queued_keys) do
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
    local text = table.concat(compressed_keys, " ")
    while #text > Config.options.win_opts.width - 2 do
        local removed = table.remove(compressed_keys, 1)
        -- HACK: don't touch this, please
        local num_removed = tonumber(string.match(removed:match("%.%.x%d$") or "1", "%d$"))
        for _ = 1, num_removed do
            table.remove(queued_keys, 1)
        end
        text = table.concat(compressed_keys, " ")
    end

    return text
end

local function display_text()
    local text = compress_output()
    -- center text inside of screenkey window
    local padding =
        string.rep(" ", math.floor((Config.options.win_opts.width - api.nvim_strwidth(text)) / 2))
    local line = math.floor(Config.options.win_opts.height / 2)
    api.nvim_buf_set_lines(bufnr, line, line + 1, false, { string.format("%s%s", padding, text) })
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
                exiting = true
                vim.schedule(function()
                    close_window()
                    create_window()
                    display_text()
                    exiting = false
                end)
            end
        end,
        desc = "make the Screenkey window persistent",
    })
end

vim.on_key(function(key, typed)
    time = 0
    if Util.should_disable() then
        return
    end
    typed = typed or key
    if not active or not typed or #typed == 0 then
        return
    end
    local transformed_keys = transform_input(typed)
    for _, k in pairs(transformed_keys) do
        table.insert(queued_keys, k)
    end
    display_text()
end, ns_id)

---@param opts? table
function M.setup(opts)
    Config.setup(opts)
end

function M.toggle()
    active = not active
    queued_keys = {}
    if active then
        create_window()
        create_autocmds()
        create_timer()
    else
        close_window()
        kill_timer()
    end
end

return M
