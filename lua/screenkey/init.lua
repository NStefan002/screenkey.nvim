local config = require("screenkey.config")
local core = require("screenkey.core")
local ui = require("screenkey.ui")

---@class screenkey.api
local M = {}

---@param opts? screenkey.config
function M.setup(opts)
    config.setup(opts)
end

function M.toggle()
    core:toggle()
end

function M.redraw()
    core:redraw()
end

---@return boolean
function M.is_active()
    return ui:is_active()
end

---@return string
function M.get_keys()
    return core:get_keys()
end

vim.on_key(core:on_key(), vim.g.screenkey_ns_id)

return M
