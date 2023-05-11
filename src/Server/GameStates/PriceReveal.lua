local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local logger = CreateLogger(script)

local function PriceReveal(system)
    return Promise.new(function(resolve)
        local replicatedRoundState = system:GetRoundStateContainer()
        local productData = system:GetCurrentProduct()

        replicatedRoundState:Patch({
            phase = "PriceReveal",
            price = productData.PriceInRobux
        })

        local finalGuesses = system:GetGuesses()
        system:CloseGuessing()
        logger.print("Final guesses are in!", finalGuesses)

        task.wait(7)
        logger.print("Reveal over")

        resolve(system:GetStateByName("AwardPoints"))
    end)
end

return PriceReveal