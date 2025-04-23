# TODO

## Features

- [x] `disable.modes` option - list of vim-modes to disable screenkey in
- [ ] `group_insert` - don't split keys when typing (if
  this is `true` and `config.options.group_mappings` is `true` then the
  insert mode mappings will be grouped and separated from 'typed' text)
- [ ] better mapping detection system (mainly for builtin mappings)
- [x] `hl_groups` - allow user to customize the predefined highlight groups such as:
  - [x] `screenkey.hl.map` - highlight group for mappings
  - [x] `screenkey.hl.key` - highlight group for non-mapping keys
  - [x] `screenkey.hl.sep` - highlight group for the separator
- [ ] `colorize` - similar as `filter` but for coloring of the keys

## Bugs

- [ ] `which-key` duplicates keys

## Other

- [ ] tests
- [ ] more logging
- [ ] `Contributing.md`
- [x] update the `README.md` with the new changes
- [ ] organize the examples in the `README.md`
- [ ] add example of the window title/border coloring to the `README.md`
- [ ] create `highlight` section for examples in the `README.md` (previous point should be included in this section)
- [x] change `disable.events` to be a separate option (e.g. `emit_events`)
