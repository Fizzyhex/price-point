local function CreateLogger(id: string)
    return {
        print = function(...)
            print(`{id}:`, ...)
        end,

        warn = function(...)
            warn(`{id}:`, ...)
        end,

        error = function(message: string, level: number)
            error(`{id}: {message}`, level)
        end,
    }
end

return CreateLogger