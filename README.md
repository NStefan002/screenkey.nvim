# Screenkey.nvim

Screenkey is a Neovim plugin that displays the keys you are typing in a floating window, just like
[screenkey](https://www.thregr.org/wavexx/software/screenkey/) does. It is useful for screencasts, presentations, and
live coding sessions.

<!-- prettier-ignore -->
> [!WARNING]
> This README tracks the `main` branch and may include *unstable* or *in-progress* features.
> For the stable version, **please switch to the latest tag release**, and refer to the `README.md` in that tag.

## 📜 Table of Contents

- [📜 Table of Contents](#-table-of-contents)
- [🧠 Why](#-why)
- [📺 Showcase](#-showcase)
- [🔥 Requirements](#-requirements)
- [📋 Installation](#-installation)
- [🔧 Configuration](#-configuration)
- [🛠 Usage](#-usage)
  - [💻 Commands](#-commands)
  - [📦 API](#-api)
  - [🎨 Customizing colors](#-customizing-colors)
  - [🧩 Statusline integration](#-statusline-integration)
  - [✨ Random examples](#-random-examples)
- [🙏 Inspiration](#-inspiration)
- [👀 Similar projects](#-similar-projects)
- [🤝 Contributing](#-contributing)

## 🧠 Why

- Don't worry about leaking your passwords (e.g. when using `sudo`) while streaming/recording because you forgot to turn
  off your display-key application, `Screenkey` will only show pieces of information about your input in Neovim.
- You can use `Screenkey` to show your keys in a presentation or a screencast, so your audience can follow along.
- You can use `Screenkey` to show your keys in a live coding session, so your neovim-newbie friends can understand what
  you are doing.

## 📺 Showcase

<https://github.com/NStefan002/screenkey.nvim/assets/100767853/29ea0949-4fd3-4d00-b5a3-2c249bb84360>

## 🔥 Requirements

- Neovim version >= 0.10.0
- a [Nerd Font](https://www.nerdfonts.com/) **_(optional, but recommended)_**

## 📋 Installation

[lazy](https://github.com/folke/lazy.nvim):

```lua
return {
    "NStefan002/screenkey.nvim",
    lazy = false,
    version = "*", -- or branch = "main", to use the latest commit
}
```

[packer](https://github.com/wbthomason/packer.nvim):

```lua
use({ "NStefan002/screenkey.nvim", tag = "*" })
```

[rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)

`:Rocks install screenkey.nvim`

<!-- prettier-ignore -->
> [!NOTE]
>
> - There is no need to call the `setup` function, only call it if you need to change some options
> - There is no need to lazy load `Screenkey`, it lazy loads by default.

## 🔧 Configuration

- Default settings

```lua
require("screenkey").setup({
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
    compress_after = 3,
    clear_after = 3,
    emit_events = true,
    disable = {
        filetypes = {},
        buftypes = {},
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
})
```

| option                | explanation                                                                                                                                                                                                                                                                                                       |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `win_opts`            | see `:h nvim_open_win`, **note1:** other options from `nvim_open_win` help can be provided (such as `win`, `bufpos`, `zindex` etc.), the ones listed above are just defaults)                                                                                                                                     |
| `hl_groups`           | highlight groups used to color different types of displayed text: **mappings**, **keys** and **separators** (see ':h nvim_set_hl()')                                                                                                                                                                              |
| `compress after`      | compress input when repeated <compress_after> times (for example `jjjj` will be compressed to `j..x4`)                                                                                                                                                                                                            |
| `clear_after`         | clear the input after `<clear_after>` seconds of inactivity                                                                                                                                                                                                                                                       |
| `emit_events`         | disable `User` events                                                                                                                                                                                                                                                                                             |
| `disable`             | temporarily disable screenkey (for specific filetype or buftype), see `:h 'filetype'` and `:h 'buftype'`                                                                                                                                                                                                          |
| `disable.filetypes`   | for example: `toggleterm` or `toml`                                                                                                                                                                                                                                                                               |
| `disable.buftypes`    | see `:h 'buftype'`, for example: `terminal`                                                                                                                                                                                                                                                                       |
| `group_mappings`      | for example: `<leader>sf` opens up a fuzzy finder, if the `group_mappings` option is set to `true`, every time you open up a fuzzy finder with `<leader>sf`, Screenkey will show `␣sf` instead of `␣ s f` to indicate that the used key combination was a defined mapping.                                        |
| `show_leader`         | if this option is set to `true`, in the last example instead of `␣ s f` Screenkey will display `<leader> s f` (of course, if the `<space>` is `<leader>`), if the current key is not a defined mapping, Screenkey will display `<space>` as `␣`                                                                   |
| `display_infront`[^1] | if the floating window containing the buffer of the same `filetype` as in `display_infront` is opened, screenkey window will be reopened in front of that window (if necessary), **Note:** you can define filetypes as lua regex, for example `"Telescope*"` to match every filetype that starts with `Telescope` |
| `display_behind`[^1]  | if the floating window containing the buffer of the same `filetype` as in `display_behind` is opened, screenkey window will be reopened behind of that window (if necessary), **Note:** you can define filetypes as lua regex, for example `"Telescope*"` to match every filetype that starts with `Telescope`    |
| `filter`              | function that takes an array of objects of type `screenkey.queued_keys`[^2] (`keys`) as input and returns a filtered array of the same keys, allowing customization of which keys should be displayed, see below for example                                                                                      |
| `colorize`            | function that takes an array of `screenkey.colored_key`s[^2] (`keys`) as input and returns a modified array with the desired highlight groups applied, this enables dynamic styling of keys based on user preferences, see below for example                                                                      |
| `separator`           | string of any length that separates the keys, space by default                                                                                                                                                                                                                                                    |
| `keys`                | how to display the special keys                                                                                                                                                                                                                                                                                   |

[^1]:
    This is currently an experimental feature. Please report any issues you encounter. Use it responsibly, do not set
    too many conditions, as it can slow down the plugin. Also, if the conflict occurs (e.g. two floating windows are
    present at the same time - one with the `filetype` that matches the `display_infront` condition and the other with
    the `filetype` that matches the `display_behind` condition), nothing will happen (this is subject to change)

[^2]: See `types.lua` file for type definitions.

## 🛠 Usage

### 💻 Commands

- `:Screenkey toggle` (or just `Screenkey`) - toggle `screenkey` on/off
- `:Screenkey redraw` - force `screenkey` to redraw
<!-- TODO: add link to examples -->
- `:Screenkey toggle_statusline_component` - toggle statusline component feature on/off (see
  [Statusline integration](#-statusline-integration))
- `:Screenkey log <arg>` - used for debugging, `<arg>` is one of the following:
  - `on` - turn on logging
  - `off` - turn off logging
  - `max_lines` - set the maximum number of lines in the log file
  - `show` - show the log file in a floating window
- `:checkhealth screenkey` - run to diagnose possible configuration problems

### 📦 API

`Screenkey` exposes a few functions that you can use in your own code:

- `setup(opts)` - override default options
- `toggle()` - toggle `screenkey` on/off
- `redraw()` - redraw `screenkey` window
- `is_active()` - check if `screenkey` is active
- `toggle_statusline_component()` - toggle statusline component feature on/off
- `statusline_component_is_active` - check if statusline component is active
- `get_keys()` - get the keys that are currently being displayed (works only if the statusline component is active)

### 🎨 Customizing colors

You can customize the colors of the keys `screenkey` displays by using the `hl_groups` option. Example:

```lua
hl_groups = {
    ["screenkey.hl.key"] = { link = "DiffAdd" },
    ["screenkey.hl.map"] = { link = "DiffDelete" },
    ["screenkey.hl.sep"] = { bg = "red", fg = "blue" },
}
```

You can customize the colors of the `screenkey` window title and border by using the `win_opts` option. Example of
highlighting title (it's basically the same thing for border, see `:h nvim_open_win()`):

```lua
win_opts = {
    title = {
        { "Sc", "DiagnosticOk" },
        { "re", "DiagnosticWarn" },
        { "en", "DiagnosticInfo" },
        { "key", "DiagnosticError" },
    },
    -- or title = { { "MY CUSTOM TITLE", "MY_CUSTOM_HIGHLIGHT_GROUP" } }
}
```

### 🧩 Statusline integration

- Lualine integration:

```lua
vim.keymap.set("n", "<leader>ts", function()
    require("screenkey").toggle_statusline_component()
end, { desc = "Toggle screenkey statusline component" })

require("lualine").setup({
    -- other options ...
    sections = {
        -- other sections ...
        lualine_c = {
            -- other components ...
            function()
                return require("screenkey").get_keys()
            end,
        },
    },
})
```

- For fully custom statusline users, `screenkey` will fire `User` events if `screenkey`'s statusline component is
  enabled. There are two patterns:
  1. `ScreenkeyUpdated` - fired on every key press
  2. `ScreenkeyCleared` - fired when clearing screenkey after some period of inactivity (see `clear_after` option)

  If you are experiencing performance issues and do not rely on these events, you can disable them by setting
  `emit_events` option to `false`. Example usage with [heirline](https://github.com/rebelot/heirline.nvim):

```lua
require("heirline").setup({
    statusline = {
        {
            provider = function()
                return require("screenkey").get_keys()
            end,
            update = {
                "User",
                pattern = "Screenkey*",
                callback = vim.schedule_wrap(function()
                    vim.cmd("redrawstatus")
                end),
            },
        },
    },
})
```

### ✨ Random examples

<!-- prettier-ignore -->
> [!NOTE]
> These are mostly not useful, but could give you some ideas.

- `nvim-notify` integration: if the `screenkey` window is open, the notification will be displayed from top down,
  otherwise it will be displayed from bottom up.

```lua
local screenkey = require("screenkey")
local notify = require("notify")
local function toggleScreenKey()
    vim.cmd("Screenkey toggle")
    -- change notification position
    notify.setup({
        top_down = screenkey.is_active(),
    })
end

vim.keymap.set("n", "<leader>tsk", toggleScreenKey, { desc = "[T]oggle [S]creen[K]ey" })
```

- If you're using terminal inside of Neovim, and you don't `screenkey` to show your keys while typing in the terminal,
  you can use the `disable.buftypes` option to disable `screenkey` when inside of the terminal.

```lua
require("screenkey").setup({
    disable = {
        buftypes = { "terminal" },
    },
})
```

- Use `filter` function to avoid displaying some keys (e.g. `h`, `j`, `k`, `l`).

```lua
require("screenkey").setup({
    filter = function(keys)
        local ignore = { "h", "j", "k", "l" }
        return vim.iter(keys)
            :filter(function(k)
                return not vim.tbl_contains(ignore, k.key)
            end)
            :totable()
    end,
})
```

## 🙏 Inspiration

- [screenkey](https://gitlab.com/screenkey/screenkey)
- [nvim-best-practices](https://github.com/nvim-neorocks/nvim-best-practices)
- [harpoon v2](https://github.com/ThePrimeagen/harpoon/tree/harpoon2)

## 👀 Similar projects

- [keys.nvim](https://github.com/tamton-aquib/keys.nvim)
- [showkeys](https://github.com/nvzone/showkeys)

## 🤝 Contributing

If you want to contribute to `screenkey.nvim`, please read the [CONTRIBUTING](CONTRIBUTING.md).
