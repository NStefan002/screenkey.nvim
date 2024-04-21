# Screenkey.nvim

Screenkey is a Neovim plugin that displays the keys you are typing in a floating window,
just like [screenkey](https://www.thregr.org/wavexx/software/screenkey/) does.
It is useful for screencasts, presentations, and live coding sessions.

## 📺 Showcase


https://github.com/NStefan002/screenkey.nvim/assets/100767853/29ea0949-4fd3-4d00-b5a3-2c249bb84360


## ⚡️ Requirements

- Neovim nightly (0.10.0+, not older than April 1st, since Screenkey requires [#28098](https://github.com/neovim/neovim/pull/28098#event-12302234671))
- a [Nerd Font](https://www.nerdfonts.com/) **_(optional, but recommended)_**

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

<details>
    <summary>Default settings:</summary>


```lua
{
    -- see :h nvim_open_win
    win_opts = {
        relative = "editor",
        anchor = "SE",
        width = 40,
        height = 3,
        border = "single",
        row = vim.o.lines - vim.o.cmdheight - 1,
        col = vim.o.columns - 1,
        -- The default `row` and `col` will put the window on the bottom left.
        -- If you want to move it to the top left, use `row = 1`.
    },
    -- compress input when repeated <compress_after> times
    compress_after = 3,
    -- clear the input after <clear_after> seconds of inactivity
    clear_after = 3,
    -- temporarily disable screenkey (for example when inside of the terminal)
    disable = {
        filetypes = {}, -- for example: "toggleterm"
        -- :h 'buftype'
        buftypes = {}, -- for example: "terminal"
    },
}
```
</details>

## ❓ How to use
- `:Screenkey` to toggle the screenkey
- Don't worry about leaking your passwords when using `sudo` while streaming/recording because you forgot to turn your display-key application,
`Screenkey` will only show pieces of information about your input in Neovim.

> [!NOTE]
> If you're using a terminal inside of the Neovim, and you want screenkey to automatically stop displaying your keys when you're inside of the terminal, see `disable` option in the plugin configuration.

## 👀 Similar projects and some differences
- [keys.nvim](https://github.com/tamton-aquib/keys.nvim):
    - As of the last update of this README, **keys.nvim** cannot process the literal keys you type - for example if you have `<c-d>` mapped to `<c-d>zz`, when you press
    `<c-d>` **keys.nvim** will show `^d z z` instead of `^d`.
    - Screenkey has `compress_after` option that enables it to compress your input - for example `jjjjjj` will be displayed as `j..x6`, which is usually way easier
    to read and will save up a lot of space.

