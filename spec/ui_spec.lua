---@diagnostic disable: invisible

local api = vim.api
local eq = assert.are.same

describe("ui", function()
    local ui = require("screenkey.ui")

    before_each(function()
        ui:close_win() -- make sure ui is closed before each test
    end)

    it("toggle ui", function()
        ui:toggle()

        eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))

        ui:toggle()

        eq(false, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(false, api.nvim_win_is_valid(vim.g.screenkey_winnr))

        ui:toggle()

        eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))

        ui:toggle()

        eq(false, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(false, api.nvim_win_is_valid(vim.g.screenkey_winnr))
    end)

    it("ui open/close", function()
        ui:open_win()

        eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))

        ui:close_win()

        eq(false, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(false, api.nvim_win_is_valid(vim.g.screenkey_winnr))

        ui:open_win()

        eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))

        ui:close_win()

        eq(false, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(false, api.nvim_win_is_valid(vim.g.screenkey_winnr))
    end)

    it("ui redraw", function()
        ui:open_win()

        eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))

        ui:redraw()

        eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
        eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))
    end)

    it("ui is_active", function()
        ui:open_win()
        eq(true, ui:is_active())

        ui:close_win()
        eq(false, ui:is_active())

        ui:toggle()
        eq(true, ui:is_active())
    end)

    -- TODO:
    it("ui update_zindex", function() end)
end)
