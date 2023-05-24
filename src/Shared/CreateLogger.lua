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

        assert = function(value: any, errorMessage: any?)
            errorMessage = errorMessage or "assertion failed!"
            assert(value, `{id}: {errorMessage}`)
        end
    }
end

return CreateLogger