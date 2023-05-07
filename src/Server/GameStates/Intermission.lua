local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local logger = CreateLogger(script)

local function Intermission(system)
    return Promise.new(function(resolve)
        local replicatedRoundState = system:GetRoundStateContainer()
        replicatedRoundState:Patch({phase = "Intermission"})

        local intermissionLength = system:GetIntermissionLength()
        logger.print(`Intermission {intermissionLength}...`)
        task.wait(intermissionLength)
        resolve(system:GetStateByName("NextRound"))
    end)
end

return Intermission