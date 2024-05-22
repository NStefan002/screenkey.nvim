local M = {}

M.check = function()
    local Config = require("screenkey.config")
    vim.health.start("screenkey.nvim")
    local ok, err = Config.validate_config(Config.options)
    if ok then
        vim.health.ok("Setup is correct")
    else
        vim.health.error(string.format("Setup is incorrect:\n%s", err))
    end
end

return M
