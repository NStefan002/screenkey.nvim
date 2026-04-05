---@diagnostic disable: invisible

local api = vim.api
local eq = assert.are.same

describe("Key utils tests", function()
    local key_utils = require("screenkey.key_utils")
    local config = require("screenkey.config")

    before_each(function()
        config.setup({})
        vim.g.mapleader = " "
    end)

    describe("split_key", function()
        it("splits plain ascii characters", function()
            eq({ "a", "b", "c" }, key_utils.split_key("abc"))
        end)

        it("splits mixed special and plain keys", function()
            eq({ "<C-a>", "b", "<M-c>" }, key_utils.split_key("<C-a>b<M-c>"))
        end)

        it("handles a <leader> token", function()
            eq({ "<leader>", "x" }, key_utils.split_key("<leader>x"))
        end)

        it("handles a lone special key", function()
            eq({ "<CR>" }, key_utils.split_key("<CR>"))
        end)

        it("handles consecutive special keys", function()
            eq({ "<C-x>", "<C-y>" }, key_utils.split_key("<C-x><C-y>"))
        end)

        it("handles a single plain character", function()
            eq({ "j" }, key_utils.split_key("j"))
        end)

        it("returns empty table for empty string", function()
            eq({}, key_utils.split_key(""))
        end)
    end)

    describe("is_special_key", function()
        it("recognises Ctrl combinations", function()
            eq(true, key_utils.is_special_key("<C-a>"))
            eq(true, key_utils.is_special_key("<C-Space>"))
            eq(true, key_utils.is_special_key("<C-Tab>"))
            eq(true, key_utils.is_special_key("<C-S-Space>"))
        end)

        it("recognises Alt/Meta/Super combinations", function()
            eq(true, key_utils.is_special_key("<M-b>"))
            eq(true, key_utils.is_special_key("<A-d>"))
            eq(true, key_utils.is_special_key("<D-d>"))
        end)

        it("recognises <...> keys that are not Ctrl/Alt/Meta/Super combinations", function()
            eq(true, key_utils.is_special_key("<CR>"))
            eq(true, key_utils.is_special_key("<TAB>"))
            eq(true, key_utils.is_special_key("<S-TAB>"))
            eq(true, key_utils.is_special_key("<F1>"))
        end)

        it("rejects plain ascii keys", function()
            eq(false, key_utils.is_special_key("a"))
            eq(false, key_utils.is_special_key("gg"))
            eq(false, key_utils.is_special_key("<"))
        end)
    end)

    describe("append_new_keys", function()
        it("increments consecutive_repeats when the trailing key matches", function()
            local queued = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
                { key = "b", is_mapping = false, consecutive_repeats = 1 },
            }
            local new = {
                { key = "b", is_mapping = false, consecutive_repeats = 1 },
                { key = "c", is_mapping = false, consecutive_repeats = 1 },
            }
            eq({
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
                { key = "b", is_mapping = false, consecutive_repeats = 2 },
                { key = "c", is_mapping = false, consecutive_repeats = 1 },
            }, key_utils.append_new_keys(queued, new))
        end)

        it("appends to an empty queue", function()
            local new = { { key = "x", is_mapping = false, consecutive_repeats = 1 } }
            eq(new, key_utils.append_new_keys({}, new))
        end)

        it("appending an empty list leaves the queue unchanged", function()
            local queued = { { key = "a", is_mapping = false, consecutive_repeats = 1 } }
            eq(queued, key_utils.append_new_keys(queued, {}))
        end)

        it("accumulates many repeats of the same key", function()
            local queued = { { key = "j", is_mapping = false, consecutive_repeats = 1 } }
            for _ = 1, 9 do
                key_utils.append_new_keys(
                    queued,
                    { { key = "j", is_mapping = false, consecutive_repeats = 1 } }
                )
            end
            eq(10, queued[1].consecutive_repeats)
        end)

        it("does not merge keys with different names", function()
            local queued = { { key = "a", is_mapping = false, consecutive_repeats = 1 } }
            local new = { { key = "b", is_mapping = false, consecutive_repeats = 1 } }
            local result = key_utils.append_new_keys(queued, new)
            eq(2, #result)
            eq("a", result[1].key)
            eq("b", result[2].key)
        end)

        it("does not merge when only is_mapping differs", function()
            local queued = { { key = "gs", is_mapping = false, consecutive_repeats = 1 } }
            local new = { { key = "gs", is_mapping = true, consecutive_repeats = 1 } }
            local result = key_utils.append_new_keys(queued, new)
            eq(1, #result)
            eq(2, result[1].consecutive_repeats)
        end)
    end)

    describe("to_string", function()
        it("renders all keys when below compress_after", function()
            local queued = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
                { key = "b", is_mapping = false, consecutive_repeats = 2 },
                { key = "c", is_mapping = false, consecutive_repeats = 3 },
            }
            eq("a b b c c c", key_utils.to_string(queued, 4, " "))
        end)

        it("compresses runs at or above compress_after", function()
            local queued = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
                { key = "b", is_mapping = false, consecutive_repeats = 2 },
                { key = "c", is_mapping = false, consecutive_repeats = 3 },
            }
            eq("a b..x2 c..x3", key_utils.to_string(queued, 2, " "))
        end)

        it("returns an empty string for an empty queue", function()
            eq("", key_utils.to_string({}, 3, " "))
        end)

        it("respects a custom separator", function()
            local queued = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
                { key = "b", is_mapping = false, consecutive_repeats = 1 },
            }
            eq("a-b", key_utils.to_string(queued, 5, "-"))
        end)

        it("does not prepend separator before the first key", function()
            local queued = { { key = "x", is_mapping = false, consecutive_repeats = 1 } }
            local result = key_utils.to_string(queued, 5, " ")
            eq("x", result)
        end)

        it("compresses a single key with many repeats into one token", function()
            local queued = { { key = "j", is_mapping = false, consecutive_repeats = 10 } }
            eq("j..x10", key_utils.to_string(queued, 3, " "))
        end)

        it("handles compress_after=1 (always compress)", function()
            local queued = { { key = "k", is_mapping = false, consecutive_repeats = 1 } }
            eq("k..x1", key_utils.to_string(queued, 1, " "))
        end)

        it("uses a multi-char separator correctly", function()
            local queued = {
                { key = "x", is_mapping = false, consecutive_repeats = 1 },
                { key = "y", is_mapping = false, consecutive_repeats = 1 },
            }
            eq("x :: y", key_utils.to_string(queued, 5, " :: "))
        end)
    end)

    describe("remove_extra_keys", function()
        it("returns an empty table unchanged", function()
            eq({}, key_utils.remove_extra_keys({}, 3, 40))
        end)

        it("removes front keys until the string fits within width - 2", function()
            local queued = {}
            for i = 1, 20 do
                table.insert(queued, {
                    key = tostring(i % 10),
                    is_mapping = false,
                    consecutive_repeats = 1,
                })
            end
            local result = key_utils.remove_extra_keys(queued, 3, 10)
            local str = key_utils.to_string(result, 3, " ")
            assert.is_true(api.nvim_strwidth(str) <= 8, "string should fit inside width-2")
        end)

        it("does not modify a queue that already fits", function()
            local queued = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
                { key = "b", is_mapping = false, consecutive_repeats = 1 },
            }
            local result = key_utils.remove_extra_keys(queued, 3, 40)
            eq(2, #result)
        end)

        it("empties the queue when even one entry cannot fit", function()
            -- "j..x50" is 6 chars
            local queued = { { key = "j", is_mapping = false, consecutive_repeats = 50 } }
            local result = key_utils.remove_extra_keys(queued, 3, 5)
            eq({}, result)
        end)

        it("removes individual repeats from the front before whole entries", function()
            -- first entry has 2 repeats, second entry has 1 repeat.
            -- if width is tight, one repeat from the front should be stripped first.
            local queued = {
                { key = "a", is_mapping = false, consecutive_repeats = 2 },
                { key = "b", is_mapping = false, consecutive_repeats = 1 },
            }
            -- "a a b" is 5 chars with space sep
            -- "a b" is 3 chars with space sep
            local result = key_utils.remove_extra_keys(queued, 5, 6)
            eq(2, #result)
        end)
    end)

    describe("colorize_keys", function()
        it("assigns screenkey.hl.key to non-mapping keys", function()
            local queued = { { key = "a", is_mapping = false, consecutive_repeats = 1 } }
            local colored = key_utils.colorize_keys(queued, 3, " ")
            eq("a", colored[1][1])
            eq("screenkey.hl.key", colored[1][2])
        end)

        it("assigns screenkey.hl.map to mapping keys", function()
            local queued = { { key = "gs", is_mapping = true, consecutive_repeats = 1 } }
            local colored = key_utils.colorize_keys(queued, 3, " ")
            eq("gs", colored[1][1])
            eq("screenkey.hl.map", colored[1][2])
        end)

        it("inserts separator pairs between keys with screenkey.hl.sep", function()
            local queued = {
                { key = "a", is_mapping = false, consecutive_repeats = 1 },
                { key = "b", is_mapping = false, consecutive_repeats = 1 },
            }
            local colored = key_utils.colorize_keys(queued, 3, "|")
            eq(3, #colored)
            eq("|", colored[2][1])
            eq("screenkey.hl.sep", colored[2][2])
        end)

        it("does not append a separator after the last key", function()
            local queued = {
                { key = "x", is_mapping = false, consecutive_repeats = 1 },
                { key = "y", is_mapping = false, consecutive_repeats = 1 },
            }
            local colored = key_utils.colorize_keys(queued, 3, " ")
            assert.are_not.equal("screenkey.hl.sep", colored[#colored][2])
        end)

        it("returns an empty list for an empty queue", function()
            eq({}, key_utils.colorize_keys({}, 3, " "))
        end)

        it("handles mixed mapping and non-mapping entries", function()
            local queued = {
                { key = "g", is_mapping = false, consecutive_repeats = 1 },
                { key = "gs", is_mapping = true, consecutive_repeats = 1 },
            }
            local colored = key_utils.colorize_keys(queued, 3, " ")
            -- g sep gs
            eq(3, #colored)
            eq("screenkey.hl.key", colored[1][2])
            eq("screenkey.hl.sep", colored[2][2])
            eq("screenkey.hl.map", colored[3][2])
        end)
    end)

    describe("transform_input", function()
        it("transforms a plain ascii key and marks it as non-mapping", function()
            local result = key_utils.transform_input("j", false, false)
            eq(1, #result)
            eq("j", result[1].key)
            eq(false, result[1].is_mapping)
            eq(1, result[1].consecutive_repeats)
        end)

        it("maps <TAB> to its configured display string", function()
            local result = key_utils.transform_input("\t", false, false)
            eq(1, #result)
            eq(config.options.keys["<TAB>"], result[1].key)
        end)

        it("maps <CR> to its configured display string", function()
            local result = key_utils.transform_input("\r", false, false)
            eq(1, #result)
            eq(config.options.keys["<CR>"], result[1].key)
        end)

        it("maps <ESC> to its configured display string", function()
            local result = key_utils.transform_input("\27", false, false)
            eq(1, #result)
            eq(config.options.keys["<ESC>"], result[1].key)
        end)

        it("maps <Space> to its configured display string", function()
            local result = key_utils.transform_input(" ", false, false)
            eq(1, #result)
            eq(config.options.keys["<SPACE>"], result[1].key)
        end)

        it("transforms Ctrl+key to a 'Ctrl+x' string", function()
            local result = key_utils.transform_input("\1", false, false) -- <c-a>
            eq(1, #result)
            assert.truthy(result[1].key:match("Ctrl"), "expected 'Ctrl' in key display")
        end)

        it("groups a mapping into one token when group_mappings=true", function()
            api.nvim_set_keymap("n", "ZZ", "<nop>", {})
            local result = key_utils.transform_input("ZZ", true, false)
            eq(1, #result)
            eq(true, result[1].is_mapping)
            api.nvim_del_keymap("n", "ZZ")
        end)

        it("does not group when group_mappings=false", function()
            api.nvim_set_keymap("n", "ZZ", "<nop>", {})
            local result = key_utils.transform_input("ZZ", false, false)
            -- two separate characters
            eq(2, #result)
            api.nvim_del_keymap("n", "ZZ")
        end)

        it("marks keys as is_mapping=true when the input matches a keymap", function()
            api.nvim_set_keymap("n", "ZZ", "<nop>", {})
            local result = key_utils.transform_input("ZZ", false, false)
            for _, k in ipairs(result) do
                eq(true, k.is_mapping)
            end
            api.nvim_del_keymap("n", "ZZ")
        end)

        it("uses a custom keys table from config for display", function()
            config.setup({ keys = { ["<TAB>"] = "TAB_CUSTOM" } })
            local result = key_utils.transform_input("\t", false, false)
            eq("TAB_CUSTOM", result[1].key)
        end)
    end)
end)
