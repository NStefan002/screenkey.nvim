local eq = assert.are.same

describe("Key utils tests", function()
    local key_utils = require("screenkey.key_utils")
    local config = require("screenkey.config")

    before_each(function()
        -- reset options to default
        config.setup()
    end)

    it("split_key", function()
        eq({ "a", "b", "c" }, key_utils.split_key("abc"))
        eq({ "<C-a>", "b", "<M-c>" }, key_utils.split_key("<C-a>b<M-c>"))
        eq({ "<leader>", "x" }, key_utils.split_key("<leader>x"))
    end)

    it("transform_input", function() end)

    it("append_new_keys", function()
        local queued_keys = {
            { key = "a", is_mapping = false, consecutive_repeats = 1 },
            { key = "b", is_mapping = false, consecutive_repeats = 1 },
        }
        local new_keys = {
            { key = "b", is_mapping = false, consecutive_repeats = 1 },
            { key = "c", is_mapping = false, consecutive_repeats = 1 },
        }
        eq({
            { key = "a", is_mapping = false, consecutive_repeats = 1 },
            { key = "b", is_mapping = false, consecutive_repeats = 2 },
            { key = "c", is_mapping = false, consecutive_repeats = 1 },
        }, key_utils.append_new_keys(queued_keys, new_keys))
    end)

    it("to_string", function()
        config.options.separator = " "
        config.options.compress_after = 4
        local queued_keys = {
            { key = "a", is_mapping = false, consecutive_repeats = 1 },
            { key = "b", is_mapping = false, consecutive_repeats = 2 },
            { key = "c", is_mapping = false, consecutive_repeats = 3 },
        }
        eq("a b b c c c", key_utils.to_string(queued_keys))
        config.options.compress_after = 2
        eq("a b..x2 c..x3", key_utils.to_string(queued_keys))
    end)

    it("remove_extra_keys", function() end)

    it("is_special_key", function()
        eq(true, key_utils.is_special_key("<C-a>"))
        eq(true, key_utils.is_special_key("<M-b>"))
        eq(true, key_utils.is_special_key("<D-c>"))
        eq(true, key_utils.is_special_key("<A-d>"))
        eq(false, key_utils.is_special_key("a"))
        eq(false, key_utils.is_special_key("gg"))
        eq(false, key_utils.is_special_key("<"))
    end)
end)
