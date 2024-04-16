local M = {}
local api = vim.api

local keys = {
    ["<tab>"] = "TAB",
    ["<cr>"] = "ENTER",
    ["<esc>"] = "ESC",
    [" "] = "SPACE",
    ["<bs>"] = "BACKSPACE",
    ["<del>"] = "DEL",
    ["<left>"] = "LEFT",
    ["<right>"] = "RIGHT",
    ["<up>"] = "UP",
    ["<down>"] = "DOWN",
    ["<home>"] = "HOME",
    ["<end>"] = "END",
    ["<pageup>"] = "PGUP",
    ["<pagedown>"] = "PGDN",
    ["<insert>"] = "INS",
    ["<f1>"] = "F1",
    ["<f2>"] = "F2",
    ["<f3>"] = "F3",
    ["<f4>"] = "F4",
    ["<f5>"] = "F5",
    ["<f6>"] = "F6",
    ["<f7>"] = "F7",
    ["<f8>"] = "F8",
    ["<f9>"] = "F9",
    ["<f10>"] = "F10",
    ["<f11>"] = "F11",
    ["<f12>"] = "F12",
    ["CTRL"] = "CTRL",
}
local transformed_keys = {}
for key, value in pairs(keys) do
    transformed_keys[vim.keycode(key)] = value
end
keys = transformed_keys

local config = {
    win_opts = {
        relative = "editor",
        anchor = "SE",
        width = 40,
        height = 3,
        border = "single",
    },
    compress_after = 2,
}

local active = false
local bufnr, winnr = -1, -1
local ns_id = api.nvim_create_namespace("screenkey")
local queued_keys = {}

local function create_window()
    if active then
        return
    end

    bufnr = api.nvim_create_buf(false, true)
    winnr = api.nvim_open_win(bufnr, false, {
        relative = config.win_opts.relative,
        anchor = config.win_opts.anchor,
        title = "Screenkey",
        title_pos = "center",
        row = vim.o.lines - vim.o.cmdheight - 1,
        col = vim.o.columns - 1,
        width = config.win_opts.width,
        height = config.win_opts.height,
        style = "minimal",
        border = config.win_opts.border,
        focusable = false,
        noautocmd = true,
    })

    if winnr == 0 then
        error("Screenkey: failed to create window")
    end

    api.nvim_set_option_value("filetype", "screenkey", { buf = bufnr })
end

local function close_window()
    if not active then
        return
    end

    if bufnr ~= -1 and api.nvim_buf_is_valid(bufnr) then
        api.nvim_buf_delete(bufnr, { force = true })
    end

    if winnr ~= -1 and api.nvim_win_is_valid(winnr) then
        api.nvim_win_close(winnr, true)
    end

    bufnr, winnr = -1, -1
end

---@param key string
---@return string
local function transform_key(key)
    if keys[key] then
        return keys[key]
    end

    ---@type string
    local translated_key = vim.fn.keytrans(key)
    -- check ctrl combo keys
    local ctrl_match = translated_key:match("^<C.-(.)>$")
    if ctrl_match then
        -- check ctrl-shift combo keys
        local shift_match = translated_key:match("^<C%-S%-.>$")
        if not shift_match then
            ctrl_match = ctrl_match:lower()
        end
        return string.format("%s+%s", keys["CTRL"], ctrl_match)
    end

    -- ignore mouse input (use keyboard!)
    if
        translated_key:match("Left")
        or translated_key:match("Right")
        or translated_key:match("Middle")
        or translated_key:match("Scroll")
    then
        return ""
    end

    return translated_key
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
            if duplicates >= config.compress_after then
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
    if duplicates >= config.compress_after then
        table.insert(compressed_keys, string.format("%s..x%d", last_key, duplicates))
    else
        for _ = 1, duplicates do
            table.insert(compressed_keys, last_key)
        end
    end

    -- remove old entries
    local text = table.concat(compressed_keys, " ")
    while #text > config.win_opts.width - 2 do
        local removed = table.remove(compressed_keys, 1)
        local num_removed = tonumber(string.match(removed:match("%.%.x%d$") or "1", "%d$"))
        -- local compressed = removed:match("%.%.x%d$")
        -- local num_removed = 1
        -- if compressed then
        --     local num = tonumber(compressed:match("%d$") or "0")
        --     num_removed = num_removed + num
        -- end
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
        string.rep(" ", math.floor((config.win_opts.width - api.nvim_strwidth(text)) / 2))
    local line = math.floor(config.win_opts.height / 2)
    api.nvim_buf_set_lines(
        bufnr,
        line,
        line + 1,
        false,
        { string.format("%s%s%s", padding, text, padding) }
    )
end

---@param opts? table
function M.setup(opts)
    config = vim.tbl_deep_extend("force", config, opts or {})
end

function M.toggle()
    if active then
        close_window()
    else
        create_window()
    end
    active = not active
end

vim.on_key(function(_, typed)
    if not active or #typed == 0 then
        return
    end
    local key = transform_key(typed)
    if #key > 0 then
        table.insert(queued_keys, transform_key(typed))
    end
    display_text()
end, ns_id)

return M
