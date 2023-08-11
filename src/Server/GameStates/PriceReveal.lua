local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local MusicController = require(ServerStorage.Server.MusicController)
local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local logger = CreateLogger(script)

local function PriceReveal(system)
    return Promise.new(function(resolve)
        local replicatedRoundState = system:GetRoundStateContainer()

        replicatedRoundState:Patch({
            phase = "PriceReveal",
            price = system:GetCurrentProductPrice(),
            roundTimer = 0
        })

        local finalGuesses = system:GetGuesses()
        system:CloseGuessing()
        MusicController.FadeOutMusic()
        logger.print("Final guesses are in!", finalGuesses)

        task.wait(7.5)
        MusicController.SetCategory("Intermission")
        task.wait(2.5)
        resolve(system:GetStateByName("RewardPoints"))
    end)
end

return PriceReveal