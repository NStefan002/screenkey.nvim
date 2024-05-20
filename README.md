# Screenkey.nvim

Screenkey is a Neovim plugin that displays the keys you are typing in a floating window,
just like [screenkey](https://www.thregr.org/wavexx/software/screenkey/) does.
It is useful for screencasts, presentations, and live coding sessions.

## 📺 Showcase

https://github.com/NStefan002/screenkey.nvim/assets/100767853/29ea0949-4fd3-4d00-b5a3-2c249bb84360

## ⚡️ Requirements

-   Neovim version >= 0.10.0
-   a [Nerd Font](https://www.nerdfonts.com/) **_(optional, but recommended)_**

## 📋 Installation

[lazy](https://github.com/folke/lazy.nvim):

```lua
{
    "NStefan002/screenkey.nvim",
    cmd = "Screenkey",
    version = "*",
    config = true,
}
```

[packer](https://github.com/wbthomason/packer.nvim):

```lua
use({
    "NStefan002/screenkey.nvim",
    config = function()
        require("screenkey").setup()
    end,
})
```

[rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)

`:Rocks install screenkey.nvim`

## ⚙️ Configuration

-   Default settings

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
    },
    compress_after = 3,
    clear_after = 3,
    disable = {
        filetypes = {},
        buftypes = {},
    },
    group_mappings = false,
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
    },
}
```

| option              | explanation                                                                                                                                                                                                                                                                                                                                         |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `win_opts`          | see `:h nvim_open_win`, **note1:** other options from `nvim_open_win` help can be provided (such as `win`, `bufpos`, `zindex` etc.), the ones listed above are just defaults, **note2:** currently, the only options that cannot be changed and will be ignored if you specify them are: `title`, `title_pos`, `style`, `focusable` and `noatocmd`) |
| `compress after`    | compress input when repeated <compress_after> times (for example `jjjj` will be compressed to `j..x4`)                                                                                                                                                                                                                                              |
| `clear_after`       | clear the input after `<clear_after>` seconds of inactivity                                                                                                                                                                                                                                                                                         |
| `disable`           | temporarily disable screenkey (for example when inside of the terminal)                                                                                                                                                                                                                                                                             |
| `disable.filetypes` | for example: `toggleterm` or `toml`                                                                                                                                                                                                                                                                                                                 |
| `disable.buftypes`  | see `:h 'buftype'`, for example: `terminal`                                                                                                                                                                                                                                                                                                         |
| `group_mappings`    | for example: `<leader>sf` opens up a fuzzy finder, if the `group_mappings` option is set to `true`, every time you open up a fuzzy finder with `<leader>sf`, Screenkey will show `␣sf` instead of `␣ s f` to indicate that the used key combination was a defined mapping.                                                                          |
| `show_leader`       | if this option is set to `true`, in the last example instead of `␣ s f` Screenkey will display `<leader> s f` (of course, if the `<space>` is `<leader>`), if the current key is not a defined mapping, Screenkey will display `<space>` as `␣`                                                                                                     |
| `keys`              | how to display the special keys                                                                                                                                                                                                                                                                                                                     |

## ❓ How to use

-   `:Screenkey` to toggle the screenkey
-   Don't worry about leaking your passwords when using `sudo` while streaming/recording because you forgot to turn your display-key application,
    `Screenkey` will only show pieces of information about your input in Neovim.

-   This plugin exposes `get_keys` function that you can use for example in a statusline component. For [lualine](https://github.com/nvim-lualine/lualine.nvim) it would look something like this:

```lua
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

> [!NOTE]
> If you're using a terminal inside of the Neovim, and you want screenkey to automatically stop displaying your keys when you're inside of the terminal, see `disable` option in the plugin configuration.

## 👀 Similar projects

-   [keys.nvim](https://github.com/tamton-aquib/keys.nvim):
