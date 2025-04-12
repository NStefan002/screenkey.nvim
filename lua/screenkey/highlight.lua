local api = vim.api
local fmt = string.format

local M = {}

local attrs = {
    fg = true,
    bg = true,
    sp = true,
    blend = true,
    bold = true,
    italic = true,
    standout = true,
    underline = true,
    undercurl = true,
    underdouble = true,
    underdotted = true,
    underdashed = true,
    strikethrough = true,
    reverse = true,
    nocombine = true,
    link = true,
    default = true,
}

local function get_hl_as_hex(opts, ns)
    ns, opts = ns or 0, opts or {}
    opts.link = opts.link ~= nil and opts.link or false
    local hl = api.nvim_get_hl(ns, opts)
    hl.fg = hl.fg and ("#%06x"):format(hl.fg)
    hl.bg = hl.bg and ("#%06x"):format(hl.bg)
    return hl
end

local function resolve_from_attribute(hl, attr)
    if type(hl) ~= "table" then
        return hl
    end
    if hl.from then
        return get_hl_as_hex({ name = hl.from })[attr] or "NONE"
    end
    return hl[attr] or "NONE"
end

function M.set(ns, name, opts)
    vim.validate({ opts = { opts, "table" }, name = { name, "string" }, ns = { ns, "number" } })
    local hl = opts.clear and {} or get_hl_as_hex({ name = opts.inherit or name })
    for attribute, hl_data in pairs(opts) do
        if attrs[attribute] then
            hl[attribute] = resolve_from_attribute(hl_data, attribute)
        end
    end
    local ok, err = pcall(api.nvim_set_hl, ns, name, hl)
    if not ok then
        local msg = fmt("Failed to set highlight %s: %s", name, err)
        require("screenkey.logger"):log(msg)
        vim.notify(msg, vim.log.levels.ERROR)
    end
end

return M

-- Adapted from
-- https://github.com/akinsho/dotfiles/blob/6f071329ab6e7846f44f105cdb1e67679fdd58c1/.config/nvim/lua/as/highlights.lua
