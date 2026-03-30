local M = {}

function M.check()
    local config = require("screenkey.config")
    vim.health.start("screenkey.nvim")
    local has_nvim_version = vim.fn.has("nvim-0.11.0") == 1
    if has_nvim_version then
        vim.health.ok("Neovim version >= 0.11.0")
    else
        vim.health.error("Neovim version < 0.11.0")
    end
    local ok, err = config.validate_config(config.options)
    if ok then
        vim.health.ok("Setup is correct")
    else
        vim.health.error(("Setup is incorrect:\n%s"):format(err))
    end
end

return M
