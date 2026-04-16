local eq = assert.are.same

describe("utils", function()
    local utils = require("screenkey.utils")

    describe("tbl_contains", function()
        it("finds an existing integer value", function()
            local t = { 1, 2, 3 }
            eq(true, utils.tbl_contains(t, 2))
            eq(true, utils.tbl_contains(t, 1))
        end)

        it("returns false for a missing value", function()
            local t = { 1, 2, 3 }
            eq(false, utils.tbl_contains(t, 4))
        end)

        it("uses a custom comparator function", function()
            local t = { "a", "b", "c" }
            local function case_insensitive(tx, v)
                return tx:upper() == v:upper()
            end
            eq(true, utils.tbl_contains(t, "A", case_insensitive))
            eq(false, utils.tbl_contains(t, "D", case_insensitive))
        end)

        it("works with a regex-style comparator (used for display_infront/behind)", function()
            local t = { "Telescope*" }
            local function regex_cmp(tx, v)
                return v:match(tx) ~= nil
            end
            eq(true, utils.tbl_contains(t, "TelescopeResults", regex_cmp))
            eq(false, utils.tbl_contains(t, "NvimTree", regex_cmp))
        end)

        it("handles an empty table", function()
            eq(false, utils.tbl_contains({}, "anything"))
        end)

        it("works with string values without a comparator", function()
            local t = { "lua", "vim", "nvim" }
            eq(true, utils.tbl_contains(t, "vim"))
            eq(false, utils.tbl_contains(t, "emacs"))
        end)
    end)

    describe("split", function()
        it("splits on whitespace by default", function()
            eq({ "hello", "world" }, utils.split("hello world"))
        end)

        it("splits on a custom separator", function()
            eq({ "a", "b ", "c" }, utils.split("a,b ,c", ","))
        end)

        it("ignores leading and trailing separators (Lua pattern behaviour)", function()
            local result = utils.split("  hello  ")
            eq({ "hello" }, result)
        end)

        it("returns a single-element table for a string with no separator", function()
            eq({ "hello" }, utils.split("hello", ","))
        end)

        it("handles multi-char separator strings", function()
            eq({ "a", "b" }, utils.split("a::b", "::"))
        end)
    end)

    describe("round", function()
        it("rounds 0.5 up", function()
            eq(5, utils.round(4.5))
        end)

        it("rounds down when fraction < 0.5", function()
            eq(4, utils.round(4.4))
        end)

        it("leaves integers unchanged", function()
            eq(7, utils.round(7))
            eq(0, utils.round(0))
        end)

        it("rounds negative numbers correctly", function()
            eq(-4, utils.round(-4.4))
            eq(-5, utils.round(-4.5))
        end)
    end)

    describe("clear_buf_lines", function()
        local bufnr

        before_each(function()
            bufnr = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line1", "line2", "line3", "line4" })
        end)

        after_each(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_delete(bufnr, { force = true })
            end
        end)

        it("clears the requested range with empty strings", function()
            utils.clear_buf_lines(bufnr, 0, 2)
            eq({ "", "", "line3", "line4" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
        end)

        it("clears the entire buffer when range covers all lines", function()
            utils.clear_buf_lines(bufnr, 0, 4)
            eq({ "", "", "", "" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
        end)

        it("clears a single line", function()
            utils.clear_buf_lines(bufnr, 1, 2)
            eq({ "line1", "", "line3", "line4" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
        end)

        it("does nothing when first == last (empty range)", function()
            utils.clear_buf_lines(bufnr, 2, 2)
            eq(
                { "line1", "line2", "line3", "line4" },
                vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            )
        end)
    end)
end)
