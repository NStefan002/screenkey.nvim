rockspec_format = "3.0"
package = "screenkey.nvim"
version = "scm-1"

local user = "NStefan002"

source = {
    url = "git+https://github.com/" .. user .. "/" .. package,
}
description = {
    homepage = "https://github.com/" .. user .. "/" .. package,
    labels = { "neovim", "neovim-plugin", "screencast" },
    license = "MIT",
    summary = "Screencast your keys in Neovim",
}
dependencies = {}
test_dependencies = {
    "nlua",
}
build = {
    type = "builtin",
    copy_directories = {
        "plugin",
    },
}
