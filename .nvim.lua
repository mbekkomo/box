vim.o.makeprg = "./bake $*"

xpcall(function()
    local ftopts = require("config.ftoptions")
    ftopts.ft.bash = ftopts.ft.sh
    ftopts.refresh()
end, function(err)
    vim.notify("exrc: "..err, vim.log.levels.ERROR)
end)
