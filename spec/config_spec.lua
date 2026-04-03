local eq = assert.are.same

describe("config", function()
    local config = require("screenkey.config")

    before_each(function()
        config.setup({})
    end)

    describe("defaults", function()
        it("has expected win_opts defaults", function()
            eq("editor", config.options.win_opts.relative)
            eq("SE", config.options.win_opts.anchor)
            eq(40, config.options.win_opts.width)
            eq(3, config.options.win_opts.height)
            eq("single", config.options.win_opts.border)
            eq(false, config.options.win_opts.focusable)
        end)

        it("has expected top-level defaults", function()
            eq(0, config.options.winblend)
            eq(3, config.options.compress_after)
            eq(3, config.options.clear_after)
            eq(true, config.options.emit_events)
            eq(false, config.options.group_mappings)
            eq(true, config.options.show_leader)
            eq(" ", config.options.separator)
            eq("echo", config.options.notify_method)
        end)

        it("has expected disable defaults (all empty)", function()
            eq({}, config.options.disable.filetypes)
            eq({}, config.options.disable.buftypes)
            eq({}, config.options.disable.modes)
        end)

        it("ships default key mappings for special keys", function()
            assert.truthy(config.options.keys["<TAB>"])
            assert.truthy(config.options.keys["<CR>"])
            assert.truthy(config.options.keys["<ESC>"])
            assert.truthy(config.options.keys["<SPACE>"])
            assert.truthy(config.options.keys["<BS>"])
            assert.truthy(config.options.keys["CTRL"])
            assert.truthy(config.options.keys["ALT"])
        end)

        it("filter default is an identity function", function()
            local keys = { { key = "a", is_mapping = false, consecutive_repeats = 1 } }
            eq(keys, config.options.filter(keys))
        end)

        it("colorize default is an identity function", function()
            local keys = { { "a", "screenkey.hl.key" } }
            eq(keys, config.options.colorize(keys))
        end)
    end)

    describe("setup", function()
        it("merges user options over defaults", function()
            config.setup({ compress_after = 10 })
            eq(10, config.options.compress_after)
        end)

        it("does not mutate fields that were not provided", function()
            config.setup({ compress_after = 99 })
            eq(3, config.options.clear_after) -- unchanged default
        end)

        it("deep-merges win_opts", function()
            config.setup({ win_opts = { width = 80 } })
            eq(80, config.options.win_opts.width)
            -- other win_opts fields should still be at their defaults
            eq("editor", config.options.win_opts.relative)
        end)

        it("deep-merges disable table", function()
            config.setup({ disable = { filetypes = { "lua" } } })
            eq({ "lua" }, config.options.disable.filetypes)
            eq({}, config.options.disable.buftypes) -- still default
        end)

        it("accepts a custom keys table entry", function()
            config.setup({ keys = { ["A"] = "shift+a" } })
            eq("shift+a", config.options.keys["A"])
        end)
    end)

    describe("validate_config", function()
        it("returns true for the default empty config", function()
            local ok, err = config.validate_config({})
            eq(true, ok)
            eq(nil, err)
        end)

        it("returns true for a fully-specified valid config", function()
            local ok, _ = config.validate_config({
                compress_after = 5,
                clear_after = 2,
                emit_events = false,
                group_mappings = true,
                show_leader = false,
                separator = "-",
                notify_method = "notify",
                winblend = 20,
            })
            eq(true, ok)
        end)

        it("returns false when compress_after is not a number", function()
            ---@diagnostic disable-next-line: assign-type-mismatch
            local ok, err = config.validate_config({ compress_after = "five" })
            eq(false, ok)
            assert.truthy(err)
        end)

        it("returns false when emit_events is not a boolean", function()
            ---@diagnostic disable-next-line: assign-type-mismatch
            local ok, _ = config.validate_config({ emit_events = "yes" })
            eq(false, ok)
        end)

        it("returns false when separator is not a string", function()
            ---@diagnostic disable-next-line: assign-type-mismatch
            local ok, _ = config.validate_config({ separator = 42 })
            eq(false, ok)
        end)

        it("returns false when filter is not a function", function()
            ---@diagnostic disable-next-line: assign-type-mismatch
            local ok, _ = config.validate_config({ filter = "not_a_function" })
            eq(false, ok)
        end)

        it("returns false when colorize is not a function", function()
            ---@diagnostic disable-next-line: assign-type-mismatch
            local ok, _ = config.validate_config({ colorize = true })
            eq(false, ok)
        end)

        it("returns false when disable contains wrong types", function()
            ---@diagnostic disable-next-line: assign-type-mismatch
            local ok, _ = config.validate_config({ disable = { filetypes = "lua" } })
            eq(false, ok)
        end)

        it("returns false for an unknown top-level key", function()
            local ok, err = config.validate_config({ unknown_option = true })
            eq(false, ok)
            assert.truthy(err:match("unknown_option"))
        end)

        it("returns false for an unknown log sub-key", function()
            local ok, err = config.validate_config({ log = { some_random_option = true } })
            eq(false, ok)
            assert.truthy(err)
        end)
    end)
end)
