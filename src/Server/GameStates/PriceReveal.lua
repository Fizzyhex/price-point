local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
        logger.print("Final guesses are in!", finalGuesses)

        task.wait(7)
        logger.print("Reveal over")

        resolve(system:GetStateByName("RewardPoints"))
    end)
end

return PriceReveal