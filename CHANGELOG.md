# Changelog

## [3.0.0](https://github.com/NStefan002/screenkey.nvim/compare/v2.4.2...v3.0.0) (2025-08-24)


### ⚠ BREAKING CHANGES

* **log:** remove `save_to_file` option, `OFF` is now default for `min_level`
* **events:** extract `emit_events` to be a separate option
* **statusline:** rework stline component and add new API for working with it
* **types:** rename `config` types

### Features

* change some log inputs ([6412873](https://github.com/NStefan002/screenkey.nvim/commit/641287339dfe1eca4f031f59469addd55f10e343))
* **command:** add `:Screenkey log clear` command ([6d96d5b](https://github.com/NStefan002/screenkey.nvim/commit/6d96d5b47e3c820edd6e568d13770ede6396c6a0))
* **config:** add `colorize` function, completes tasks in [#54](https://github.com/NStefan002/screenkey.nvim/issues/54) ([15a8552](https://github.com/NStefan002/screenkey.nvim/commit/15a8552ab27b5c9236d09a02dfcc5989ea52c7a7))
* **config:** allow any key in `config.keys` (fix [#59](https://github.com/NStefan002/screenkey.nvim/issues/59)) ([0f18732](https://github.com/NStefan002/screenkey.nvim/commit/0f187324bbe4caae453143b4e431ec3187ecec30))
* **disable:** users can now disable screenkey in specific modes ([390e379](https://github.com/NStefan002/screenkey.nvim/commit/390e3791b5bf9ebfb8f7f8bd91b014e2437527fb))
* **events:** extract `emit_events` to be a separate option ([df80952](https://github.com/NStefan002/screenkey.nvim/commit/df80952043cda3cd7165191fc4d88c8312dadb8a))
* **highlights:** define hlgroups for different types of keys ([208739a](https://github.com/NStefan002/screenkey.nvim/commit/208739a291738d7c2df32d0b6765656ff4ab82a7))
* **keys:** `consecutive_repeats` field of the `queued_key` ([d494c6b](https://github.com/NStefan002/screenkey.nvim/commit/d494c6bbf884023627040560e3f1a530b50dd5ed))
* **log:** add `save_to_file` and `filepath` log options ([d9833ba](https://github.com/NStefan002/screenkey.nvim/commit/d9833baf0422728787377425fb195a219e4c9ea1))
* **log:** remove `save_to_file` option, `OFF` is now default for `min_level` ([52fdb94](https://github.com/NStefan002/screenkey.nvim/commit/52fdb941fe6d208b1dea8e489cc0f8d433e4973e))
* **log:** rework `logger` ([9605131](https://github.com/NStefan002/screenkey.nvim/commit/9605131792a23902e00bbd4ccb747f4207267053))
* **separator:** introduce separator between displayed keys ([9366ee3](https://github.com/NStefan002/screenkey.nvim/commit/9366ee3374a18d4a099d117194b0502ef9584b1e))
* **statusline:** rework stline component and add new API for working with it ([37171c4](https://github.com/NStefan002/screenkey.nvim/commit/37171c430accedd6e5540a3b8ae47d76b137d799))
* **types:** more precise types for highlights ([a8d95f2](https://github.com/NStefan002/screenkey.nvim/commit/a8d95f2bbd974404443707754a31d2c71393ccbd))
* **ui:** set `winfixbuf` for `screenkey` window ([cc83075](https://github.com/NStefan002/screenkey.nvim/commit/cc830750de70328c2bd3d845e349e7cc456b8892))
* **utils:** improve errors styling ([5706541](https://github.com/NStefan002/screenkey.nvim/commit/570654185e94a4d49b911d1e0dc15b857e7cdc26))


### Bug Fixes

* **commands:** remove old `log` subcommands ([008e7cb](https://github.com/NStefan002/screenkey.nvim/commit/008e7cb52c7777c2b06ba62e85e543d490c1e451))
* **config:** don't fall back to default config if the config is invalid ([1c61a57](https://github.com/NStefan002/screenkey.nvim/commit/1c61a57d82d415695e2ee3806d18f75f187ca19f))
* **core:** filter keys should be applied for statusline too ([961be36](https://github.com/NStefan002/screenkey.nvim/commit/961be36ca5f2d2d52eb265bd77284cc084f113ee))
* **core:** statusline component bug ([9285cae](https://github.com/NStefan002/screenkey.nvim/commit/9285cae2004c7b0cb7b7136bc4af17aa7c176f47))
* **lint:** `prettierd` conflicts with `markdownlint` rules ([689ae10](https://github.com/NStefan002/screenkey.nvim/commit/689ae10ed0acf140d5f6dd1bd68a7134b3121eca))
* partial fix for [#47](https://github.com/NStefan002/screenkey.nvim/issues/47) ([a2f9f29](https://github.com/NStefan002/screenkey.nvim/commit/a2f9f29519f5d1d7309e6ef8f21dc9cdb0cd0866))
* **ui:** update `active` field ([6d6c889](https://github.com/NStefan002/screenkey.nvim/commit/6d6c88922283c8227353d26dcf00f3254a73289e))
* use `nvim_strwidth` instead of `#` ([1dddfce](https://github.com/NStefan002/screenkey.nvim/commit/1dddfcea0ee26989f55f4574d128c86b3d64a1d5))
* **utils:** increment/decrement z-index accordingly ([bcdf8f8](https://github.com/NStefan002/screenkey.nvim/commit/bcdf8f8fd2ab5f44e1733a6fd9a6f09f86dbb500))
* **util:** use `nvim_win_set_config()` instead of redrawing ([8adb110](https://github.com/NStefan002/screenkey.nvim/commit/8adb110adab9f5a30df8e3ac6241267b450186f1))


### Reverts

* "refactor(types)!: rename `config` types" ([01dc077](https://github.com/NStefan002/screenkey.nvim/commit/01dc077eb0f26568c98f35a7508fb1e8f24ec58f))


### Code Refactoring

* **types:** rename `config` types ([f309701](https://github.com/NStefan002/screenkey.nvim/commit/f3097016862133290e02edf517c52705479fe24e))

## [2.4.2](https://github.com/NStefan002/screenkey.nvim/compare/v2.4.1...v2.4.2) (2024-12-09)


### Bug Fixes

* **util:** check for buffer-local mappings ([aa4c7d9](https://github.com/NStefan002/screenkey.nvim/commit/aa4c7d9a8e96df43da7d8eff7b8d8edc0c21f2ac))

## [2.4.1](https://github.com/NStefan002/screenkey.nvim/compare/v2.4.0...v2.4.1) (2024-09-06)


### Bug Fixes

* handle editor resizing (closes [#25](https://github.com/NStefan002/screenkey.nvim/issues/25)) ([408661f](https://github.com/NStefan002/screenkey.nvim/commit/408661f96d6e17090eee9251e0566cd934729737))

## [2.4.0](https://github.com/NStefan002/screenkey.nvim/compare/v2.3.3...v2.4.0) (2024-08-18)


### Features

* expose active state ([7019de5](https://github.com/NStefan002/screenkey.nvim/commit/7019de50780a4f3ccb7a5f4bbef44fa843f7cccc))

## [2.3.3](https://github.com/NStefan002/screenkey.nvim/compare/v2.3.2...v2.3.3) (2024-08-12)


### Bug Fixes

* show UNICODE keys (see [#37](https://github.com/NStefan002/screenkey.nvim/issues/37)) ([430bc60](https://github.com/NStefan002/screenkey.nvim/commit/430bc60cc703f7bfbd10853cac14cc8b6ee82679))

## [2.3.2](https://github.com/NStefan002/screenkey.nvim/compare/v2.3.1...v2.3.2) (2024-08-11)


### Bug Fixes

* invalid bufnr in scheduled function ([a90c0bb](https://github.com/NStefan002/screenkey.nvim/commit/a90c0bbbbe2ae17facaaa89ec7b475b612393101))

## [2.3.1](https://github.com/NStefan002/screenkey.nvim/compare/v2.3.0...v2.3.1) (2024-08-08)


### Bug Fixes

* screenkey + `getcharstr` inside of expression mappings ([#36](https://github.com/NStefan002/screenkey.nvim/issues/36)) ([4f03ed0](https://github.com/NStefan002/screenkey.nvim/commit/4f03ed00211a9c1ac6ce25ca734794a101466ed3))

## [2.3.0](https://github.com/NStefan002/screenkey.nvim/compare/v2.2.1...v2.3.0) (2024-08-08)


### Features

* rework the `filter` function ([8d1298e](https://github.com/NStefan002/screenkey.nvim/commit/8d1298e735d8612747d8f07074a2f71c85765647))
* users can now implement `filter` function ([4fa463e](https://github.com/NStefan002/screenkey.nvim/commit/4fa463ec93910ab5fa48c4797b28b7d7056fd78e))


### Bug Fixes

* **util:** `is_mapping` no longer produces false results ([9a5d22e](https://github.com/NStefan002/screenkey.nvim/commit/9a5d22e67cbbdb41eaf63887eecc80bacfba676c))

## [2.2.1](https://github.com/NStefan002/screenkey.nvim/compare/v2.2.0...v2.2.1) (2024-07-05)


### Bug Fixes

* **command:** `*` not needed in regex ([ecd1887](https://github.com/NStefan002/screenkey.nvim/commit/ecd1887649c56e8a339f08444f2fb0cf7f556753))

## [2.2.0](https://github.com/NStefan002/screenkey.nvim/compare/v2.1.0...v2.2.0) (2024-07-03)


### Features

* **config:** allow users to set all of the win_opts ([1a7d6d5](https://github.com/NStefan002/screenkey.nvim/commit/1a7d6d590c0a06edb2ab9c54603304c859366111))

## [2.1.0](https://github.com/NStefan002/screenkey.nvim/compare/v2.0.0...v2.1.0) (2024-06-15)


### Features

* fire user events ([0df9640](https://github.com/NStefan002/screenkey.nvim/commit/0df9640f04ca9668a1084128a21a40b0a70089a2))

## [2.0.0](https://github.com/NStefan002/screenkey.nvim/compare/v1.4.1...v2.0.0) (2024-06-13)


### ⚠ BREAKING CHANGES

* **config:** `show_leader` is now `true` by default

### Features

* add an option for map-grouping ([7f93737](https://github.com/NStefan002/screenkey.nvim/commit/7f93737c0344814421edfb1fa6739db70c016da9))
* add an option to show `leader` in mappings ([a2b9372](https://github.com/NStefan002/screenkey.nvim/commit/a2b9372ebe6c3eb0344b681241290a2c68e070a4))
* **api:** expose `get_keys` function ([f3e2df4](https://github.com/NStefan002/screenkey.nvim/commit/f3e2df47b6f8134da6a5d336d23688ebaa66f578))
* **api:** provide `redraw` function ([a853a75](https://github.com/NStefan002/screenkey.nvim/commit/a853a754f72536154faa8c437df82366315fb45a))
* **config:** `show_leader` is now `true` by default ([f03995d](https://github.com/NStefan002/screenkey.nvim/commit/f03995df0bf7793f6a59e2e3da7da015845392cf))
* **config:** add an option to customize `&lt;leader&gt;` symbol ([7b54d74](https://github.com/NStefan002/screenkey.nvim/commit/7b54d7417ebf875b11236dbe8eb59116e41ba980))
* **config:** added types for options ([da19003](https://github.com/NStefan002/screenkey.nvim/commit/da1900302bcf266e4e83f6ac15bde5356f158a9f))
* **config:** move `keys` to config ([09f1692](https://github.com/NStefan002/screenkey.nvim/commit/09f169239e5eb3c8180fe929463e2cbcb4ef178a))
* **config:** support (almost) all of the `nvim_open_win` opts ([18ba235](https://github.com/NStefan002/screenkey.nvim/commit/18ba235915b88fa92c7590bc5aae015f9a523101))
* **config:** use api types for `win_opts` ([805e958](https://github.com/NStefan002/screenkey.nvim/commit/805e9582af94db70d42dec1c2de56628177c0b01))
* **config:** users can now specify `row` and `col` ([2f16f53](https://github.com/NStefan002/screenkey.nvim/commit/2f16f5345c308c6a6b216a4aa199bff2247527c6))
* **config:** validate user config ([9dfeffb](https://github.com/NStefan002/screenkey.nvim/commit/9dfeffb00954ff2f5374ef4619a99d68517a147f))
* **health:** `:checkhealth screenkey` support ([e636ef3](https://github.com/NStefan002/screenkey.nvim/commit/e636ef3874489a659971325ff2e2ceef7e391e92))
* implement config module ([c398ade](https://github.com/NStefan002/screenkey.nvim/commit/c398ade44df2fd1cf82f1b08ad77a5622b48d69d))
* **init:** no need to call `setup` function ([8c56222](https://github.com/NStefan002/screenkey.nvim/commit/8c56222272bbe2e9bc46be560b217945d140572e))
* introduce display_infront/behind ([7ff6fb0](https://github.com/NStefan002/screenkey.nvim/commit/7ff6fb08b3af7cb27889060ec906b1a72d190d65))
* **logger:** implement simple logger ([86f3b00](https://github.com/NStefan002/screenkey.nvim/commit/86f3b006bea16ad0ae5e2c8281833e49c5733814))
* make the Screenkey window persistent ([39af61f](https://github.com/NStefan002/screenkey.nvim/commit/39af61f0342eefbc8abb5f015d75977e3d1f19bd))
* **statusline-component:** toggle statusline component ([#19](https://github.com/NStefan002/screenkey.nvim/issues/19)) ([7806e34](https://github.com/NStefan002/screenkey.nvim/commit/7806e344029ca0ce2773250e54783454869f4933))
* **user commands:** add various subcommands ([b2cfe5e](https://github.com/NStefan002/screenkey.nvim/commit/b2cfe5eef8bb979d7ba0c2805042fbbdb10e9582))
* **user commands:** logger commands ([3d585e6](https://github.com/NStefan002/screenkey.nvim/commit/3d585e6b2d0889d4cbfdb2d2235acd6e75accbf9))
* **util:** optional function for comparing values in tbl_contains ([9fe269a](https://github.com/NStefan002/screenkey.nvim/commit/9fe269ade03f19508295f6adfe45f35936fb010e))


### Bug Fixes

* ignore mouse input, record left and right arrow keys ([d5beab2](https://github.com/NStefan002/screenkey.nvim/commit/d5beab2f880180da1d4ab38419d7284fa06eadc4))
* **user commands:** copy pasta... ([d064501](https://github.com/NStefan002/screenkey.nvim/commit/d06450149328ec43794b72cc9700470ba94f2e1f))

## [1.4.1](https://github.com/NStefan002/screenkey.nvim/compare/v1.4.0...v1.4.1) (2024-05-02)


### Bug Fixes

* remove unnecessary padding ([ff32c3e](https://github.com/NStefan002/screenkey.nvim/commit/ff32c3e875daa085872377ae8f50d066df3cef30))

## [1.4.0](https://github.com/NStefan002/screenkey.nvim/compare/v1.3.1...v1.4.0) (2024-04-20)


### Features

* **tabs:** move the screenkey to the current tab-page ([fe9c1e8](https://github.com/NStefan002/screenkey.nvim/commit/fe9c1e8d45309347df8a16d879bb687238892a83))

## [1.3.1](https://github.com/NStefan002/screenkey.nvim/compare/v1.3.0...v1.3.1) (2024-04-18)


### Bug Fixes

* `typed` is a nil value, screenkey shows nothing ([6dc082f](https://github.com/NStefan002/screenkey.nvim/commit/6dc082f5e4cb9e316866801275fcd371fa0c5350))

## [1.3.0](https://github.com/NStefan002/screenkey.nvim/compare/v1.2.1...v1.3.0) (2024-04-17)


### Features

* **config:** disable screenkey for specified file/buf types ([82b00c6](https://github.com/NStefan002/screenkey.nvim/commit/82b00c6bbb01c74024eb8ebed52edb08a905d9e6))

## [1.2.1](https://github.com/NStefan002/screenkey.nvim/compare/v1.2.0...v1.2.1) (2024-04-17)


### Bug Fixes

* `typed` is a nil value ([1d0db12](https://github.com/NStefan002/screenkey.nvim/commit/1d0db12f947fd5020998d9b6523dff5ad05e8179))
* render space correctly ([8aa833f](https://github.com/NStefan002/screenkey.nvim/commit/8aa833f0961f47a0fc68849c4f4da5ed7cb4c620))

## [1.2.0](https://github.com/NStefan002/screenkey.nvim/compare/v1.1.0...v1.2.0) (2024-04-16)


### Features

* **timer:** clear screenkey buffer after specified time ([f7204a4](https://github.com/NStefan002/screenkey.nvim/commit/f7204a414ff374f290c7ac3e808584af0f949c7a))

## [1.1.0](https://github.com/NStefan002/screenkey.nvim/compare/v1.0.0...v1.1.0) (2024-04-16)


### Features

* **keys:** recognize ctrl/alt/super/shift key combination ([bc3c9e9](https://github.com/NStefan002/screenkey.nvim/commit/bc3c9e9ad6e65b276ad41e97cc53750596e520b2))


### Bug Fixes

* **keys:** prevent `key = nil` errors, reset `queued_keys` ([796350c](https://github.com/NStefan002/screenkey.nvim/commit/796350c01edf0662785df30a9eed340d57907c43))

## 1.0.0 (2024-04-16)


### Features

* basic features ([e2d4cd1](https://github.com/NStefan002/screenkey.nvim/commit/e2d4cd1e101c20c16dafe52760124f9a27f0968e))
* **icons:** add icons for most of the keys ([e3ba462](https://github.com/NStefan002/screenkey.nvim/commit/e3ba46277382a3716392cd997f1b3f0cf878028a))
* **input:** correctly parse multikey input ([67cb25c](https://github.com/NStefan002/screenkey.nvim/commit/67cb25cbb75bc7703649757b1b88dd6644fd935a))
