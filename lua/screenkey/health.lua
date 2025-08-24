local M = {}

function M.check()
    local config = require("screenkey.config")
    vim.health.start("screenkey.nvim")
    local ok, err = config.validate_config(config.options)
    if ok then
        vim.health.ok("Setup is correct")
    else
        vim.health.error(string.format("Setup is incorrect:\n%s", err))
    end
end

return M
