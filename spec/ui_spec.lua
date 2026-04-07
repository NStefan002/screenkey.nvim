---@diagnostic disable: invisible

local api = vim.api
local eq = assert.are.same

describe("ui", function()
    local ui = require("screenkey.ui")
    local config = require("screenkey.config")

    before_each(function()
        ui:close_win()
        config.setup({})
    end)

    describe("toggle", function()
        it("opens a valid buffer and window on first toggle", function()
            ui:toggle()
            eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
            eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))
        end)

        it("closes buffer and window on second toggle", function()
            ui:toggle()
            ui:toggle()
            eq(false, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
            eq(false, api.nvim_win_is_valid(vim.g.screenkey_winnr))
        end)

        it("reopens correctly after being closed", function()
            ui:toggle()
            ui:toggle()
            ui:toggle()
            eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
            eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))
        end)
    end)

    describe("open_win / close_win", function()
        it("open creates a valid buffer and window", function()
            ui:open_win()
            eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
            eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))
        end)

        it("closes buffer and window properly", function()
            ui:open_win()
            ui:close_win()
            eq(false, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
            eq(false, api.nvim_win_is_valid(vim.g.screenkey_winnr))
        end)

        it("resets screenkey_bufnr and screenkey_winnr to -1 after close", function()
            ui:open_win()
            ui:close_win()
            eq(-1, vim.g.screenkey_bufnr)
            eq(-1, vim.g.screenkey_winnr)
        end)

        it("calling open_win twice does not create two windows", function()
            ui:open_win()
            local first_winnr = vim.g.screenkey_winnr
            ui:open_win()
            -- should reuse the existing window
            eq(first_winnr, vim.g.screenkey_winnr)
        end)
    end)

    describe("is_active", function()
        it("returns false when the ui is closed", function()
            eq(false, ui:is_active())
        end)

        it("returns true after open_win", function()
            ui:open_win()
            eq(true, ui:is_active())
        end)

        it("returns false after close_win", function()
            ui:open_win()
            ui:close_win()
            eq(false, ui:is_active())
        end)

        it("tracks state through multiple toggles", function()
            eq(false, ui:is_active())
            ui:toggle()
            eq(true, ui:is_active())
            ui:toggle()
            eq(false, ui:is_active())
        end)
    end)

    describe("redraw", function()
        it("keeps ui active after a redraw", function()
            ui:open_win()
            ui:redraw()
            eq(true, api.nvim_buf_is_valid(vim.g.screenkey_bufnr))
            eq(true, api.nvim_win_is_valid(vim.g.screenkey_winnr))
        end)

        it("creates a new window id after a redraw (close + re-open)", function()
            ui:open_win()
            local old_winnr = vim.g.screenkey_winnr
            ui:redraw()
            assert.are_not.equal(old_winnr, vim.g.screenkey_winnr)
        end)

        it("nothing happens when ui is inactive", function()
            ui:redraw()
            eq(false, ui:is_active())
        end)
    end)

    describe("window options applied on open", function()
        it("sets the filetype to 'screenkey' on the buffer", function()
            ui:open_win()
            local ft = api.nvim_get_option_value("filetype", { buf = vim.g.screenkey_bufnr })
            eq("screenkey", ft)
        end)

        it("applies the configured winblend", function()
            config.setup({ winblend = 30 })
            ui:open_win()
            local blend = api.nvim_get_option_value("winblend", { win = vim.g.screenkey_winnr })
            eq(30, blend)
        end)

        it("applies winblend=0 by default", function()
            ui:open_win()
            local blend = api.nvim_get_option_value("winblend", { win = vim.g.screenkey_winnr })
            eq(0, blend)
        end)

        it("window is not focusable", function()
            ui:open_win()
            local win_config = api.nvim_win_get_config(vim.g.screenkey_winnr)
            eq(false, win_config.focusable)
        end)
    end)

    describe("update_zindex", function()
        it("increases zindex when infront=true and a target buffer is in a window", function()
            ui:open_win()

            -- Open a second floating window with a known buffer
            local target_buf = api.nvim_create_buf(false, true)
            local target_win = api.nvim_open_win(target_buf, false, {
                relative = "editor",
                width = 10,
                height = 3,
                row = 0,
                col = 0,
                style = "minimal",
                zindex = 50,
            })

            ui:update_zindex(target_buf, true)
            local screenkey_cfg = api.nvim_win_get_config(vim.g.screenkey_winnr)
            -- zindex should now be 51 (50 + 1)
            eq(51, screenkey_cfg.zindex)

            api.nvim_win_close(target_win, true)
            api.nvim_buf_delete(target_buf, { force = true })
        end)

        it("decreases zindex when infront=false", function()
            ui:open_win()

            local target_buf = api.nvim_create_buf(false, true)
            local target_win = api.nvim_open_win(target_buf, false, {
                relative = "editor",
                width = 10,
                height = 3,
                row = 0,
                col = 0,
                style = "minimal",
                zindex = 50,
            })

            ui:update_zindex(target_buf, false)
            local screenkey_cfg = api.nvim_win_get_config(vim.g.screenkey_winnr)
            -- zindex should now be 49 (50 - 1)
            eq(49, screenkey_cfg.zindex)

            api.nvim_win_close(target_win, true)
            api.nvim_buf_delete(target_buf, { force = true })
        end)
    end)
end)
