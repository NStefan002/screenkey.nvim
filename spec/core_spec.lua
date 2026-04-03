---@diagnostic disable: invisible

local eq = assert.are.same

describe("core", function()
    local core = require("screenkey.core")
    local ui = require("screenkey.ui")
    local config = require("screenkey.config")

    before_each(function()
        ui:close_win()
        config.setup({})
    end)

    describe("toggle", function()
        it("opens the ui on first toggle", function()
            core:toggle()
            eq(true, ui:is_active())
        end)

        it("closes the ui on second toggle", function()
            core:toggle()
            core:toggle()
            eq(false, ui:is_active())
        end)

        it("clears queued_keys on toggle", function()
            core.queued_keys = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
            }
            core:toggle()
            eq({}, core.queued_keys)
        end)
    end)

    describe("statusline component", function()
        it("is inactive by default", function()
            eq(false, core:statusline_component_is_active())
        end)

        it("toggle", function()
            core:toggle_statusline_component()
            eq(true, core:statusline_component_is_active())
            core:toggle_statusline_component()
            eq(false, core:statusline_component_is_active())
        end)
    end)

    describe("get_keys", function()
        it("returns empty string when statusline component is inactive", function()
            core.queued_keys = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
            }
            eq("", core:get_keys())
        end)

        it("returns the stringified keys when statusline component is active", function()
            core:toggle_statusline_component()
            core.queued_keys = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
                { key = "b", is_mapping = false, consecutive_repeats = 1 },
            }
            local result = core:get_keys()
            assert.truthy(result:match("a"))
            assert.truthy(result:match("b"))
        end)

        it("returns empty string when queue is empty even if component is active", function()
            core:toggle_statusline_component()
            core.queued_keys = {}
            eq("", core:get_keys())
        end)
    end)

    describe("redraw", function()
        it("keeps the ui active after a redraw", function()
            core:toggle() -- open
            core:redraw()
            eq(true, ui:is_active())
        end)
    end)

    describe("on_key callback", function()
        local handler

        before_each(function()
            handler = core:on_key()
        end)

        it("returns a callable", function()
            eq("function", type(handler))
        end)

        it("does not error when ui is inactive and statusline component is inactive", function()
            assert.has_no.errors(function()
                handler("j", "j")
            end)
        end)

        it("does not error on nil typed argument", function()
            -- nvim sometimes passes nil for typed
            assert.has_no.errors(function()
                handler("j", nil)
            end)
        end)

        it("does not error on empty typed argument", function()
            assert.has_no.errors(function()
                handler("j", "")
            end)
        end)

        it("appends keys to queued_keys when ui is active", function()
            core:toggle() -- activate ui
            handler("a", "a")
            assert.is_true(#core.queued_keys > 0, "expected queued_keys to be non-empty")
        end)

        it("applies the user filter function", function()
            config.setup({
                filter = function(keys)
                    return vim.iter(keys)
                        :filter(function(k)
                            return k.key ~= "x"
                        end)
                        :totable()
                end,
            })
            core = require("screenkey.core")
            core:toggle()
            handler = core:on_key()

            handler("x", "x")
            vim.wait(50)
            -- "x" should have been filtered out
            for _, k in ipairs(core.queued_keys) do
                assert.are_not.equal("x", k.key)
            end
        end)
    end)
end)
