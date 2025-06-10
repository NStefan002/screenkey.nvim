local plugin_path = vim.uv.fs_realpath("./")
vim.opt.rtp:append(plugin_path)
-- source all files in plugin/ directory
vim.cmd("runtime! plugin/**/*.{vim,lua}")
