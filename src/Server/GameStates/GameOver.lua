local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)

local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local logger = CreateLogger(script)

local function GameOver()
    return Promise.new(function(resolve)
        logger.print("Game over - restarting in 5s")
        task.wait(5)
        resolve(false)
    end)
end

return GameOver