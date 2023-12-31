local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateContainers = require(ReplicatedStorage.Shared.StateContainers)
local roundStateContainer = StateContainers.roundStateContainer
local GameStateChannel = require(ReplicatedStorage.Client.EventChannels.GameStateChannel)

-- Observes game state and fires off `GameStateChannel` events
local function GameStateObserver()
    local stopObservingRoundState = roundStateContainer:Observe(function(oldState, newState)
        if oldState.phase == newState.phase then
            return
        end

        if newState.phase == "GameOver" then
            GameStateChannel.RaiseGameOver()
        elseif oldState.phase == "PriceReveal" then
            GameStateChannel.RaiseRoundOver()
        end

        if newState.phase == "PriceReveal" then
           GameStateChannel.RaisePriceRevealBegun()
        elseif oldState.phase == "PriceReveal" then
            GameStateChannel.RaisePriceRevealEnded()
        end
    end)

    return function()
        stopObservingRoundState()
    end
end

return GameStateObserver