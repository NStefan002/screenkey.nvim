local M = {}

---@type screenkey.config.full
M.defaults = {
    win_opts = {
        row = vim.o.lines - vim.o.cmdheight - 1,
        col = vim.o.columns - 1,
        relative = "editor",
        anchor = "SE",
        width = 40,
        height = 3,
        border = "single",
        title = "Screenkey",
        title_pos = "center",
        style = "minimal",
        focusable = false,
        noautocmd = true,
    },
    compress_after = 3,
    clear_after = 3,
    disable = {
        filetypes = {},
        buftypes = {},
        events = false,
    },
    show_leader = true,
    group_mappings = false,
    -- TODO: group_text = false
    display_infront = {},
    display_behind = {},

    filter = function(keys)
        return keys
    end,

    keys = {
        ["<TAB>"] = "󰌒",
        ["<CR>"] = "󰌑",
        ["<ESC>"] = "Esc",
        ["<SPACE>"] = "␣",
        ["<BS>"] = "󰌥",
        ["<DEL>"] = "Del",
        ["<LEFT>"] = "",
        ["<RIGHT>"] = "",
        ["<UP>"] = "",
        ["<DOWN>"] = "",
        ["<HOME>"] = "Home",
        ["<END>"] = "End",
        ["<PAGEUP>"] = "PgUp",
        ["<PAGEDOWN>"] = "PgDn",
        ["<INSERT>"] = "Ins",
        ["<F1>"] = "󱊫",
        ["<F2>"] = "󱊬",
        ["<F3>"] = "󱊭",
        ["<F4>"] = "󱊮",
        ["<F5>"] = "󱊯",
        ["<F6>"] = "󱊰",
        ["<F7>"] = "󱊱",
        ["<F8>"] = "󱊲",
        ["<F9>"] = "󱊳",
        ["<F10>"] = "󱊴",
        ["<F11>"] = "󱊵",
        ["<F12>"] = "󱊶",
        ["CTRL"] = "Ctrl",
        ["ALT"] = "Alt",
        ["SUPER"] = "󰘳",
        ["<leader>"] = "<leader>",
    },
    highlights = {
        Float = { inherit = "NormalFloat" },
        FloatBorder = { inherit = "FloatBorder" },
        ScreenKey = { bg = { from = "NormalFloat" }, fg = { from = "Comment" } },
    },
}

---@type screenkey.config.full
M.options = M.defaults

---@param opts? screenkey.config
function M.setup(opts)
    opts = opts or {}
    local ok, err = M.validate_config(opts)
    if not ok then
        require("screenkey.logger"):log(err)
        vim.notify(
            "Invalid configuration for screenkey.nvim, run ':checkhealth screenkey' for more information",
            vim.log.levels.ERROR
        )
    end
    M.options = vim.tbl_deep_extend("force", M.defaults, opts)
end

---@param config screenkey.config
---@return boolean, string?
function M.validate_config(config)
    local Util = require("screenkey.util")

    ---@type string[]
    local errors = {}
    local ok, err = Util.validate({
        win_opts = { config.win_opts, "table", true },
        compress_after = { config.compress_after, "number", true },
        clear_after = { config.clear_after, "number", true },
        disable = { config.disable, "table", true },
        show_leader = { config.show_leader, "boolean", true },
        group_mappings = { config.group_mappings, "boolean", true },
        display_infront = { config.display_infront, "table", true },
        display_behind = { config.display_behind, "table", true },
        filter = { config.filter, "function", true },
        keys = { config.keys, "table", true },
        highlights = { config.highlights, "table", true },
    }, config, "screenkey.config")

    if not ok then
        table.insert(errors, err)
    end

    if config.disable then
        ok, err = Util.validate({
            filetypes = { config.disable.filetypes, "table", true },
            buftypes = { config.disable.buftypes, "table", true },
            events = { config.disable.events, "boolean", true },
        }, config.disable, "screenkey.config.disable")
        if not ok then
            table.insert(errors, err)
        end
    end

    if config.keys then
        local validation = {}
        for key, value in pairs(M.defaults.keys) do
            validation[key] = { value, "string", true }
        end
        ok, err = Util.validate(validation, config.keys, "screenkey.config.keys")
        if not ok then
            table.insert(errors, err)
        end
    end

    if config.highlights then
        local valid_hl_attrs = {
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
            inherit = true,
            from = true,
        }
        ok, err = Util.validate({
            Float = { config.highlights.Float, "table", true },
            FloatBorder = { config.highlights.FloatBorder, "table", true },
            ScreenKey = { config.highlights.ScreenKey, "table", true },
        }, config.highlights, "screenkey.config.highlights")
        if not ok then
            table.insert(errors, err)
        else
            for name, hl in pairs(config.highlights) do
                for attr, value in pairs(hl) do
                    if not valid_hl_attrs[attr] then
                        table.insert(
                            errors,
                            string.format("Invalid highlight attribute '%s' for %s", attr, name)
                        )
                    elseif attr == "fg" or attr == "bg" or attr == "sp" then
                        if type(value) ~= "string" or not value:match("^#[0-9a-fA-F]{6}$") then
                            table.insert(
                                errors,
                                string.format(
                                    "Invalid color value '%s' for %s.%s (must be #RRGGBB)",
                                    tostring(value),
                                    name,
                                    attr
                                )
                            )
                        end
                    elseif attr == "blend" then
                        if type(value) ~= "number" or value < 0 or value > 100 then
                            table.insert(
                                errors,
                                string.format(
                                    "Invalid blend value '%s' for %s (must be 0-100)",
                                    tostring(value),
                                    name
                                )
                            )
                        end
                    elseif attr == "inherit" or attr == "from" or attr == "link" then
                        if type(value) ~= "string" then
                            table.insert(
                                errors,
                                string.format(
                                    "Invalid %s value '%s' for %s (must be a string)",
                                    attr,
                                    tostring(value),
                                    name
                                )
                            )
                        end
                    elseif type(value) ~= "boolean" then
                        table.insert(
                            errors,
                            string.format(
                                "Invalid %s value '%s' for %s (must be boolean)",
                                attr,
                                tostring(value),
                                name
                            )
                        )
                    end
                end
            end
        end
    end

    if #errors == 0 then
        return true, nil
    end
    return false, table.concat(errors, "\n")
end

return M
