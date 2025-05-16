---@class (exact) screenkey.config.full
--- see ':h nvim_open_win()'
---@field win_opts vim.api.keyset.win_config
--- see ':h nvim_set_hl()'
---@field hl_groups table<screenkey.hl_group, vim.api.keyset.highlight>
--- compress input when repeated <compress_after> times
---@field compress_after integer
--- clear the input after `<clear_after>` seconds of inactivity
---@field clear_after number
--- weather or not to emit autocmd events, useful for fully custom statusline
---@field emit_events boolean
--- disable screenkey in specific filetype (`:h 'filetype'`), buftype (`:h 'buftype'`) or mode (`:h mode()`)
---@field disable { filetypes: string[], buftypes: string[], modes: string[] }
--- show '<leader>' in mappings
---@field show_leader boolean
--- display mappings in groups
---@field group_mappings boolean
--- if screenkey is overlapping with the floating window that
--- contains a buffer with the following filetypes, display
--- the screenkey in front of the floating window
---@field display_infront string[]
--- if screenkey is overlapping with the floating window that
--- contains a buffer with the following filetypes, display
--- the screenkey behind the floating window
---@field display_behind string[]
--- filter the keys before displaying them
---@field filter fun(keys: screenkey.queued_key[]): screenkey.queued_key[]
--- optionally change the highlight groups used to highlight mappings, regular keys and separators
---@field colorize fun(keys: screenkey.colored_key[]): screenkey.colored_key[]
--- string to display in-between the keys
---@field separator string
--- how to display the special keys
---@field keys table<string, string>
--- how to display notifications
---@field notify_method "none" | "notify" | "echo"
--- logger settings
---@field log screenkey.config.log.full

---@class (exact) screenkey.config : screenkey.config.full, {}
---@field log screenkey.config.log

---@class (exact) screenkey.config.log.full
---@field min_level vim.log.levels

---@class (exact) screenkey.config.log : screenkey.config.log.full, {}

---@class screenkey.queued_key
---@field key string
---@field is_mapping boolean
---@field consecutive_repeats integer

---@alias screenkey.hl_group
---| "screenkey.hl.key"
---| "screenkey.hl.map"
---| "screenkey.hl.sep"

---@class screenkey.pair<T1, T2> { [1]: T1, [2]: T2 }

---@alias screenkey.colored_key screenkey.pair<string, screenkey.hl_group>

---@alias screenkey.notification_message screenkey.pair<string, vim.log.levels>
