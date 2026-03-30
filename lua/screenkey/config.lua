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
    hl_groups = {
        ["screenkey.hl.key"] = { link = "Normal" },
        ["screenkey.hl.map"] = { link = "Normal" },
        ["screenkey.hl.sep"] = { link = "Normal" },
    },
    winblend = 0,
    compress_after = 3,
    clear_after = 3,
    emit_events = true,
    disable = {
        filetypes = {},
        buftypes = {},
        modes = {},
    },
    show_leader = true,
    group_mappings = false,
    display_infront = {},
    display_behind = {},
    filter = function(keys)
        return keys
    end,
    colorize = function(keys)
        return keys
    end,
    separator = " ",
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
    notify_method = "echo",
    log = {
        min_level = vim.log.levels.OFF,
        filepath = vim.fn.stdpath("data") .. "/screenkey_log",
    },
}

---@type screenkey.config.full
M.options = M.defaults

---@param opts? screenkey.config
function M.setup(opts)
    opts = opts or {}
    local ok, err = M.validate_config(opts)
    local log = require("screenkey.log")
    if not ok then
        log:notify(vim.log.levels.ERROR, {
            {
                "invalid configuration, plugin may function improperly\nrun",
                vim.log.levels.OFF,
            },
            { " :checkhealth screenkey ", vim.log.levels.INFO },
            { "for more details", vim.log.levels.OFF },
        })
        log:error(err)
    else
        log:info("options setup done without errors")
    end
    M.options = vim.tbl_deep_extend("force", M.defaults, opts)
end

---@param config screenkey.config
---@return boolean, string?
function M.validate_config(config)
    local utils = require("screenkey.utils")

    ---@type string[]
    local errors = {}
    local ok, err = utils.validate({
        win_opts = { config.win_opts, "table", true },
        hl_groups = { config.hl_groups, "table", true },
        winblend = { config.winblend, "number", true },
        compress_after = { config.compress_after, "number", true },
        clear_after = { config.clear_after, "number", true },
        emit_events = { config.emit_events, "boolean", true },
        disable = { config.disable, "table", true },
        show_leader = { config.show_leader, "boolean", true },
        group_mappings = { config.group_mappings, "boolean", true },
        display_infront = { config.display_infront, "table", true },
        display_behind = { config.display_behind, "table", true },
        filter = { config.filter, "function", true },
        colorize = { config.colorize, "function", true },
        separator = { config.separator, "string", true },
        keys = { config.keys, "table", true },
        notify_method = { config.notify_method, "string", true },
        log = { config.log, "table", true },
    }, config, "screenkey.config")

    if not ok then
        table.insert(errors, err)
    end

    if config.disable then
        ok, err = utils.validate({
            filetypes = { config.disable.filetypes, "table", true },
            buftypes = { config.disable.buftypes, "table", true },
            modes = { config.disable.modes, "table", true },
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
        ok, err = utils.validate_keytable(validation, config.keys, "screenkey.config.keys")
        if not ok then
            table.insert(errors, err)
        end
    end

    if config.log then
        ok, err = utils.validate({
            min_level = { config.log.min_level, "number", true },
            filepath = { config.log.filepath, "string", true },
        }, config.log, "screenkey.config.log")
        if not ok then
            table.insert(errors, err)
        end
    end

    if #errors == 0 then
        return true, nil
    end
    return false, table.concat(errors, "\n")
end

return M
