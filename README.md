# Screenkey.nvim

Screenkey is a Neovim plugin that displays the keys you are typing in a floating window,
just like [screenkey](https://www.thregr.org/wavexx/software/screenkey/) does.
It is useful for screencasts, presentations, and live coding sessions.

## 📺 Showcase

<https://github.com/NStefan002/screenkey.nvim/assets/100767853/29ea0949-4fd3-4d00-b5a3-2c249bb84360>

## ⚡️ Requirements

- Neovim version >= 0.10.0
- a [Nerd Font](https://www.nerdfonts.com/) **_(optional, but recommended)_**

## 📋 Installation

[lazy](https://github.com/folke/lazy.nvim):

```lua
{
    "NStefan002/screenkey.nvim",
    lazy = false,
    version = "*", -- or branch = "dev", to use the latest commit
}
```

[packer](https://github.com/wbthomason/packer.nvim):

```lua
use({ "NStefan002/screenkey.nvim", tag = "*" })
```

[rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)

`:Rocks install screenkey.nvim`

> [!NOTE]
>
> - There is no need to call the `setup` function, only call it if you need to change some options
> - There is no need to lazy load `Screenkey`, it lazy loads by default.

## ⚙️ Configuration

- Default settings

```lua
{
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
    },
    show_leader = true,
    group_mappings = false,
    display_infront = {},
    display_behind = {},
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
}
```

| option                | explanation                                                                                                                                                                                                                                                                                                                                         |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `win_opts`            | see `:h nvim_open_win`, **note1:** other options from `nvim_open_win` help can be provided (such as `win`, `bufpos`, `zindex` etc.), the ones listed above are just defaults) |
| `compress after`      | compress input when repeated <compress_after> times (for example `jjjj` will be compressed to `j..x4`)                                                                                                                                                                                                                                              |
| `clear_after`         | clear the input after `<clear_after>` seconds of inactivity                                                                                                                                                                                                                                                                                         |
| `disable`             | temporarily disable screenkey (for example when inside of the terminal)                                                                                                                                                                                                                                                                             |
| `disable.filetypes`   | for example: `toggleterm` or `toml`                                                                                                                                                                                                                                                                                                                 |
| `disable.events`      | disable `User` events                                                                                                                                                                                                                                                                                                                               |
| `disable.buftypes`    | see `:h 'buftype'`, for example: `terminal`                                                                                                                                                                                                                                                                                                         |
| `group_mappings`      | for example: `<leader>sf` opens up a fuzzy finder, if the `group_mappings` option is set to `true`, every time you open up a fuzzy finder with `<leader>sf`, Screenkey will show `␣sf` instead of `␣ s f` to indicate that the used key combination was a defined mapping.                                                                          |
| `show_leader`         | if this option is set to `true`, in the last example instead of `␣ s f` Screenkey will display `<leader> s f` (of course, if the `<space>` is `<leader>`), if the current key is not a defined mapping, Screenkey will display `<space>` as `␣`                                                                                                     |
| `display_infront`[^1] | if the floating window containing the buffer of the same `filetype` as in `display_infront` is opened, screenkey window will be reopened in front of that window (if necessary), **Note:** you can define filetypes as lua regex, for example `"Telescope*"` to match every filetype that starts with `Telescope`                                   |
| `display_behind`[^2]  | if the floating window containing the buffer of the same `filetype` as in `display_behind` is opened, screenkey window will be reopened behind of that window (if necessary), **Note:** you can define filetypes as lua regex, for example `"Telescope*"` to match every filetype that starts with `Telescope`                                      |
| `keys`                | how to display the special keys                                                                                                                                                                                                                                                                                                                     |

[^1]:
    This is currently an experimental feature. Please report any issues you encounter. Use it responsibly, do not set too many conditions, as it can slow down the plugin.
    Also, if the conflict occurs (e.g. two floating windows are present at the same time - one with the `filetype` that matches the `display_infront` condition and the other with the `filetype` that matches the `display_behind` condition), nothing will happen (this is subject to change)

[^2]: Same as above

## ❓ How to use

- `:Screenkey toggle` (or just `Screenkey`) to toggle the screenkey
- Don't worry about leaking your passwords when using `sudo` while streaming/recording because you forgot to turn off your
display-key application, `Screenkey` will only show pieces of information about your input in Neovim.

- This plugin exposes `get_keys` function that you can use in a statusline component. You can use `:Screenkey toggle_statusline_component`
or change `vim.g.screenkey_statusline_component` to toggle this feature on/off. For [lualine](https://github.com/nvim-lualine/lualine.nvim)
it would look something like this:

```lua
vim.g.screenkey_statusline_component = true

vim.keymap.set("n", "<leader>ssc", function()
    vim.g.screenkey_statusline_component = not vim.g.screenkey_statusline_component
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

- Run `:checkhealth screenkey` to diagnose possible configuration problems

- `Screenkey` exposes `redraw` function that redraws the `Screenkey` window, could be used like this:

```lua
require("screenkey").redraw()
```

or

`:Screenkey redraw`

> [!NOTE]
> If you're using a terminal inside of the Neovim, and you want screenkey to automatically stop displaying your
keys when you're > inside of the terminal, see `disable` option in the plugin configuration.

- For fully custom statusline users, screenkey will fire `User` events if `vim.g.screenkey_statusline_component` is enabled.
There are two patterns: `ScreenkeyUpdated` on keypress and `ScreenkeyCleared` when clearing screenkey after inactivity
(see `clear_after` option). If you are experiencing performance issues and do not rely on these events, you can disable
them with the `disable.events` option. Example usage with [heirline](https://github.com/rebelot/heirline.nvim):

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

## 🙏 I took inspiration (and some code) from

- [nvim-best-practices](https://github.com/nvim-neorocks/nvim-best-practices)
- [harpoon v2](https://github.com/ThePrimeagen/harpoon/tree/harpoon2)

## 👀 Similar projects

- [keys.nvim](https://github.com/tamton-aquib/keys.nvim):
