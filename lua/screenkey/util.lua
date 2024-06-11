local M = {}
local api = vim.api
local Config = require("screenkey.config")

---@param t table Table to check
---@param value any Value to compare or predicate function reference
---@param f? fun(tx: any, v: any): boolean Function to compare values (fist argument is table value, second is value to compare)
---@return boolean `true` if `t` contains `value`
function M.tbl_contains(t, value, f)
    f = f or function(tx, v)
        return tx == v
    end
    for _, tx in pairs(t) do
        if f(tx, value) then
            return true
        end
    end
    return false
end

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

function M.should_disable()
    local filetype = api.nvim_get_option_value("filetype", { buf = 0 })
    if M.tbl_contains(Config.options.disable.filetypes, filetype) then
        return true
    end

    local buftype = api.nvim_get_option_value("buftype", { buf = 0 })
    if M.tbl_contains(Config.options.disable.buftypes, buftype) then
        return true
    end

    return false
end

---@param key string
---@return boolean
function M.is_mapping(key)
    local mode = api.nvim_get_mode()
    local mappings = api.nvim_get_keymap(mode.mode)
    for _, mapping in ipairs(mappings) do
        if
            ---@diagnostic disable-next-line: undefined-field
            key:upper() == mapping.lhs:upper()
            ---@diagnostic disable-next-line: undefined-field
            or key:upper() == vim.fn.keytrans(mapping.lhs):upper()
        then
            return true
        end
    end

    return false
end

---@param opts table
---@param user_config table
---@param path string
---@return boolean, string?
function M.validate(opts, user_config, path)
    local ok, err = pcall(vim.validate, opts)
    if not ok then
        return false, string.format("%s: %s", path, err)
    end

    local errors = {}
    for key, _ in pairs(user_config) do
        if not opts[key] then
            table.insert(errors, string.format("'%s' is not a valid key of %s", key, path))
        end
    end

    if #errors == 0 then
        return true, nil
    end
    return false, table.concat(errors, "\n")
end

return M
