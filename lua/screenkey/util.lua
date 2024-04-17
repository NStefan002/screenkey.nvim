local M = {}

---@param t table Table to check
---@param value any Value to compare or predicate function reference
---@return boolean `true` if `t` contains `value`
M.tbl_contains = function(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

return M
