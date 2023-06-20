local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local PriceReveal = require(ReplicatedStorage.Client.UI.Components.PriceReveal)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)
local Signal = require(ReplicatedStorage.Packages.Signal)

local ANCESTORS = { workspace }

local function PriceRevealDisplay()
    return Observers.observeTag("PriceRevealDisplay", function(parent: Instance)
        local playEvent = Signal.new()
        local endEvent = Signal.new()
        local isAnimationRunning = false

        local stopObservingRoundState = RoundStateContainer:Observe(function(oldState, newState)
            if newState.price and newState.phase == "PriceReveal" and isAnimationRunning == false then
                isAnimationRunning = true
                playEvent:Fire(newState.price)
            elseif isAnimationRunning then
                isAnimationRunning = false
                endEvent:Fire()
            end
        end)

        local ui = PriceReveal {
            PlayEvent = playEvent,
            EndEvent = endEvent,
            Parent = parent
        }

        return function()
            stopObservingRoundState()
            ui:Destroy()
        end
    end, ANCESTORS)
end

return PriceRevealDisplay