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
---@param in_key string
---@return screenkey.queued_key[]
function M.transform_input(in_key)
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
            )
        then
            local leader = vim.g.mapleader or ""
            if
                config.options.show_leader
                and is_mapping
                and (k:upper() == leader:upper() or k:upper() == vim.fn.keytrans(leader):upper())
            then
                table.insert(
                    transformed_keys,
                    { key = config.options.keys["<leader>"], is_mapping = true }
                )
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
                        })
                    elseif modifier == "A" or modifier == "M" then
                        table.insert(transformed_keys, {
                            key = string.format("%s+%s", config.options.keys["ALT"], key),
                            is_mapping = is_mapping,
                        })
                    elseif modifier == "D" then
                        table.insert(transformed_keys, {
                            key = string.format("%s+%s", config.options.keys["SUPER"], key),
                            is_mapping = is_mapping,
                        })
                    end
                end
            else
                table.insert(
                    transformed_keys,
                    { key = config.options.keys[k:upper()] or k, is_mapping = is_mapping }
                )
            end
        end
    end

    if config.options.group_mappings and #transformed_keys > 0 and is_mapping then
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

---TODO: return should be screenkey.queued_key[]
---@param queued_keys screenkey.queued_key[]
---@return string
function M.compress_output(queued_keys)
    local compressed_keys = {}

    local last_key = queued_keys[1] and queued_keys[1].key or ""

    local duplicates = 0
    for _, queued_key in ipairs(queued_keys) do
        local key = queued_key.key
        if key == last_key then
            duplicates = duplicates + 1
        else
            if duplicates >= config.options.compress_after then
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
    if duplicates >= config.options.compress_after then
        table.insert(compressed_keys, string.format("%s..x%d", last_key, duplicates))
    else
        for _ = 1, duplicates do
            table.insert(compressed_keys, last_key)
        end
    end

    -- remove old entries
    local text = table.concat(compressed_keys, config.options.separator)
    while api.nvim_strwidth(text) > config.options.win_opts.width - 2 do
        local removed = table.remove(compressed_keys, 1)
        -- HACK: don't touch this, please
        local num_removed = tonumber(string.match(removed:match("%.%.x%d$") or "1", "%d$"))
        for _ = 1, num_removed do
            table.remove(queued_keys, 1)
        end
        text = table.concat(compressed_keys, config.options.separator)
    end

    return text
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

return M
