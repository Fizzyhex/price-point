local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)

local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local logger = CreateLogger(script)

local function NextRound(system)
    return Promise.new(function(resolve)
        if system:GetRoundsRemaining() > 0 then
            system:GetRoundStateContainer():Clear()
            system:DecreaseRoundsRemaining()
            resolve(system:GetStateByName("PriceGuessing"))
        else
            resolve(system:GetStateByName("GameOver"))
        end
    end)
end

return NextRound