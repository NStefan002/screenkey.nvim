local eq = assert.are.same

describe("utils", function()
    local utils = require("screenkey.utils")

    describe("tbl_contains", function()
        local t = { 1, 2, 3 }
        eq(true, utils.tbl_contains(t, 2))
        eq(true, utils.tbl_contains(t, 1))
        eq(false, utils.tbl_contains(t, 4))

        t = { "a", "b", "c" }
        local function f(a, b)
            return a:upper() == b:upper()
        end
        eq(true, utils.tbl_contains(t, "A", f))
    end)

    describe("split", function()
        eq({ "hello", "world" }, utils.split("hello world"))
        eq({ "a", "b", "c" }, utils.split("a,b,c", ","))
    end)

    describe("round", function()
        eq(5, utils.round(4.5))
        eq(4, utils.round(4.4))
    end)

    describe("clear_buf_lines", function()
        local bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "line1", "line2", "line3" })

        utils.clear_buf_lines(bufnr, 0, 2)
        eq({ "", "", "line3" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))

        utils.clear_buf_lines(bufnr, 0, 4)
        eq({ "", "", "", "" }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    end)
end)
