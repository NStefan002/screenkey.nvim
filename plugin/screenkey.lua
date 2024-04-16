vim.api.nvim_create_user_command("Screenkey", function(event)
    if #event.fargs > 0 then
        error("Screenkey: command does not accept arguments")
    end
    require("screenkey").toggle()
end, {
    nargs = 0,
    desc = "Toggle Screenkey",
})
