local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)
local GameStateChannel = require(ReplicatedStorage.Client.EventChannels.GameStateChannel)

-- Observes game state and fires off `GameStateChannel` events
local function GameStateObserver()
    local stopObservingRoundState = RoundStateContainer:Observe(function(oldState, newState)
        if oldState.phase == newState.phase then
            return
        end

        if newState.phase == "GameOver" then
            GameStateChannel.RaiseGameOver()
        end
    end)

    return function()
        stopObservingRoundState()
    end
end

return GameStateObserver