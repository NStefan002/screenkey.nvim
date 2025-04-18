# TODO

## Features

- [ ] `disable.modes` option - list of vim-modes to disable screenkey in
- [ ] `group_insert` - don't split keys when typing (if
  this is `true` and `config.options.group_mappings` is `true` then the
  insert mode mappings will be grouped and separated from 'typed' text)
- [ ] better mapping detection system (mainly for builtin mappings)
- [ ] `hl_groups` - allow user to customize the predefined highlight groups such as:
  - [ ] `screenkey.hl.mapping` - highlight group for mappings
  - [ ] `screenkey.hl.key` - highlight group for non-mapping keys
  - [ ] `screenkey.hl.sep` - highlight group for the separator
- [ ] `colorize` - similar as `filter` but for coloring of the keys

## Bugs

- [ ] `which-key` duplicates keys

## Other

- [ ] tests
- [ ] `Contributing.md`
- [ ] update the `README.md` with the new changes
- [ ] organize the examples in the `README.md`
