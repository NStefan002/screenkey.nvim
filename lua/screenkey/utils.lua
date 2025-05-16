local api = vim.api

local M = {}

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

---@param str string string to split
---@param sep? string separator (whitespace by default)
function M.split(str, sep)
    sep = sep or "%s"
    local t = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, s)
    end
    return t
end

---rounds x to the nearest integer
---@param x number
---@return integer
function M.round(x)
    return math.floor(x + 0.5)
end

---@param bufnr integer
---@param first integer first line index (inclusive, 0-indexed)
---@param last integer last line index (exclusive, 0-indexed)
function M.clear_buf_lines(bufnr, first, last)
    local repl = {}
    for _ = first, last - 1 do
        table.insert(repl, "")
    end
    api.nvim_buf_set_lines(bufnr, first, last, false, repl)
end

return M
