# TODO

## Features

- [x] `disable.modes` option - list of vim-modes to disable screenkey in
- [ ] `group_insert` - don't split keys when typing (if this is `true` and `config.options.group_mappings` is `true`
      then the insert mode mappings will be grouped and separated from 'typed' text)
- [ ] better mapping detection system (mainly for builtin mappings)
- [x] `hl_groups` - allow user to customize the predefined highlight groups such as:
  - [x] `screenkey.hl.map` - highlight group for mappings
  - [x] `screenkey.hl.key` - highlight group for non-mapping keys
  - [x] `screenkey.hl.sep` - highlight group for the separator
- [x] `colorize` - similar as `filter` but for coloring of the keys

## Bugs

- [ ] `which-key` duplicates keys
- [x] when neovim starts (and there is an error in the `config`), `screenkey` reports an error with
      `\[...\] run :checkhealth screenkey for more details`, but the default `config` is used when the error occurs, so
      the `:checkhealth screenkey` command does not show any errors in `config`

## Other

- [ ] tests
- [ ] more logging
- [x] `Contributing.md`
- [x] update the `README.md` with the new changes
- [ ] organize the examples in the `README.md`
- [ ] create `highlight` section for examples in the `README.md`
  - [x] add example of the window title/border coloring to the `README.md`
  - [ ] add example of the key coloring to the `README.md`
- [x] change `disable.events` to be a separate option (e.g. `emit_events`)
- [x] rework `logger` and add option to set the log level
- [x] use `nvim_echo` to report messages (mainly in the `health` module)
- [ ] remove deprecated `vim.validate()`
- [x] add examples of how to solve [#59](https://github.com/NStefan002/screenkey.nvim/issues/59)
