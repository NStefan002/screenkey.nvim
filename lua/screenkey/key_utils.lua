local api = vim.api
local config = require("screenkey.config")

local M = {}

---@param key string
---@return string[] split
function M.split_key(key)
    local split = {}
    local tmp = ""
    local diamond_open = false
    for i = 1, #key do
        local curr_char = key:sub(i, i)
        tmp = tmp .. curr_char
        if curr_char == "<" then
            diamond_open = true
        elseif curr_char == ">" then
            diamond_open = false
        end
        if not diamond_open then
            table.insert(split, tmp)
            tmp = ""
        end
    end
    return split
end

--- Explanation:
--- Vim sometimes packs multiple keys into one input, e.g. `jk` when exiting insert mode with `jk`.
--- For this reason, we need to split the input into individual keys and transform them into the
--- corresponding symbols.
--- see `:h keytrans()`
---
--- If `group_mappings` or `show_leader` are not provided, use the value from `config.options`
---@param in_key string
---@param group_mappings? boolean
---@param show_leader? boolean
---@return screenkey.queued_key[]
function M.transform_input(in_key, group_mappings, show_leader)
    if group_mappings == nil then
        group_mappings = config.options.group_mappings
    end
    if show_leader == nil then
        show_leader = config.options.show_leader
    end

    in_key = vim.fn.keytrans(in_key)
    local is_mapping = M.is_mapping(in_key)
    local split = api.nvim_strwidth(in_key) > 1 and M.split_key(in_key) or { in_key }
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
                or k:match("Drag") ~= nil --TODOB
            )
        then
            local leader = vim.g.mapleader or ""
            if
                show_leader
                and is_mapping
                and (k:upper() == leader:upper() or k:upper() == vim.fn.keytrans(leader):upper())
            then
                table.insert(transformed_keys, {
                    key = config.options.keys["<leader>"],
                    is_mapping = true,
                    consecutive_repeats = 1,
                })
            elseif M.is_special_key(k) then
                local modifier = k:match("^<([CMAD])%-.+>$")
                local key = k:match("^<.-%-.*(.)>$")
                local shift = k:match("^<.-%-(S)%-.>$") ~= nil

                if key ~= nil then
                    if not shift then
                        key = key:lower()
                    end
                    if modifier == "C" then
                        table.insert(transformed_keys, {
                            key = string.format("%s+%s", config.options.keys["CTRL"], key),
                            is_mapping = is_mapping,
                            consecutive_repeats = 1,
                        })
                    elseif modifier == "A" or modifier == "M" then
                        table.insert(transformed_keys, {
                            key = string.format("%s+%s", config.options.keys["ALT"], key),
                            is_mapping = is_mapping,
                            consecutive_repeats = 1,
                        })
                    elseif modifier == "D" then
                        table.insert(transformed_keys, {
                            key = string.format("%s+%s", config.options.keys["SUPER"], key),
                            is_mapping = is_mapping,
                            consecutive_repeats = 1,
                        })
                    end
                end
            else
                table.insert(transformed_keys, {
                    key = config.options.keys[k] or k, ---TODOB
                    is_mapping = is_mapping,
                    consecutive_repeats = 1,
                })
            end
        end
    end

    if group_mappings and #transformed_keys > 0 and is_mapping then
        return {
            {
                key = table.concat(
                    vim.tbl_map(function(k)
                        return k.key
                    end, transformed_keys),
                    ""
                ),
                is_mapping = true,
                consecutive_repeats = 1,
            },
        }
    else
        return transformed_keys
    end
end

---@param queued_keys screenkey.queued_key[]
---@param new_keys screenkey.queued_key[]
---@return screenkey.queued_key[]
function M.append_new_keys(queued_keys, new_keys)
    for _, k in ipairs(new_keys) do
        if #queued_keys > 0 and k.key == queued_keys[#queued_keys].key then
            queued_keys[#queued_keys].consecutive_repeats = queued_keys[#queued_keys].consecutive_repeats
                + 1
        else
            table.insert(queued_keys, k)
        end
    end

    return queued_keys
end

--- Convert a list of queued keys to a string.
---
--- If `compress_after` or `separator` are not provided, use the value from `config.options`
---@param queued_keys screenkey.queued_key[]
---@param compress_after? integer
---@param separator? string
---@return string
function M.to_string(queued_keys, compress_after, separator)
    compress_after = compress_after or config.options.compress_after
    separator = separator or config.options.separator

    local str = ""

    for _, k in ipairs(queued_keys) do
        if k.consecutive_repeats >= compress_after then
            str = ("%s%s%s..x%d"):format(
                str,
                str == "" and "" or separator, -- don't add separator before first key
                k.key,
                k.consecutive_repeats
            )
        else
            for _ = 1, k.consecutive_repeats do
                str = ("%s%s%s"):format(
                    str,
                    str == "" and "" or separator, -- don't add separator before first key
                    k.key
                )
            end
        end
    end

    return str
end

--- Remove extra keys from the list if the string representation of the keys
--- exceeds the given width.
---
--- If `compress_after` or `width` are not provided, use the value from `config.options`
---@param queued_keys screenkey.queued_key[]
---@param compress_after? integer
---@param width? integer
---@return screenkey.queued_key[]
function M.remove_extra_keys(queued_keys, compress_after, width)
    if #queued_keys == 0 then
        return queued_keys
    end

    compress_after = compress_after or config.options.compress_after
    width = width or config.options.win_opts.width

    local text = M.to_string(queued_keys)
    while api.nvim_strwidth(text) > width - 2 do
        if queued_keys[1].consecutive_repeats >= compress_after then
            table.remove(queued_keys, 1)
        else
            queued_keys[1].consecutive_repeats = queued_keys[1].consecutive_repeats - 1
            if queued_keys[1].consecutive_repeats == 0 then
                table.remove(queued_keys, 1)
            end
        end
        text = M.to_string(queued_keys)
    end

    return queued_keys
end

---@param key string
---@return boolean
function M.is_mapping(key)
    local mode = api.nvim_get_mode()
    local mappings = api.nvim_get_keymap(mode.mode)
    vim.list_extend(mappings, api.nvim_buf_get_keymap(0, mode.mode))
    for _, mapping in ipairs(mappings) do
        ---@diagnostic disable-next-line: undefined-field
        if key == mapping.lhs or key == vim.fn.keytrans(mapping.lhs) then
            return true
        end
    end

    return false
end

---@param key string
---@return boolean
function M.is_special_key(key)
    return key:match("^<([CMAD])%-.+>$") ~= nil
end

--- NOTE: subject to change in the future

--- Creates a list of key-highlight pairs from the given queued keys.
---
--- If `compress_after` or `separator` are not provided, use the value from `config.options`
---@param queued_keys screenkey.queued_key[]
---@param compress_after? integer
---@param separator? string
---@return screenkey.colored_key[]
function M.colorize_keys(queued_keys, compress_after, separator)
    compress_after = compress_after or config.options.compress_after
    separator = separator or config.options.separator

    ---@type screenkey.colored_key[]
    local colorized_keys = {}
    for i, qkey in ipairs(queued_keys) do
        if qkey.consecutive_repeats < compress_after then
            for j = 1, qkey.consecutive_repeats do
                table.insert(colorized_keys, {
                    qkey.key,
                    qkey.is_mapping and "screenkey.hl.map" or "screenkey.hl.key",
                })
                if i < #queued_keys or j < qkey.consecutive_repeats then
                    table.insert(colorized_keys, {
                        separator,
                        "screenkey.hl.sep",
                    })
                end
            end
        else
            table.insert(colorized_keys, {
                M.to_string({ qkey }),
                qkey.is_mapping and "screenkey.hl.map" or "screenkey.hl.key",
            })
            if i < #queued_keys then
                table.insert(colorized_keys, {
                    separator,
                    "screenkey.hl.sep",
                })
            end
        end
    end

    return colorized_keys
end

return M
