local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local PriceReveal = require(ReplicatedStorage.Client.UI.Components.PriceReveal)
local StateContainers = require(ReplicatedStorage.Shared.StateContainers)
local roundStateContainer = StateContainers.roundStateContainer
local Signal = require(ReplicatedStorage.Packages.Signal)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)
local GameStateChannel = require(ReplicatedStorage.Client.EventChannels.GameStateChannel)

local ANCESTORS = { workspace }

local function PriceRevealDisplay()
    return Observers.observeTag("PriceRevealDisplay", function(parent: Instance)
        local binAdd, binEmpty = Bin()
        local playEvent = Signal.new()
        local endEvent = Signal.new()
        local onFinalPriceRevealed = Signal.new()
        local isAnimationRunning = false

        binAdd(roundStateContainer:Observe(function(oldState, newState)
            if newState.price and newState.phase == "PriceReveal" and isAnimationRunning == false then
                isAnimationRunning = true
                playEvent:Fire(newState.price)
            elseif isAnimationRunning then
                isAnimationRunning = false
                endEvent:Fire()
            end
        end))

        binAdd(onFinalPriceRevealed:Connect(GameStateChannel.RaisePriceAnimationEnded))

        local ui = PriceReveal {
            PlayEvent = playEvent,
            EndEvent = endEvent,
            OnFinalPriceRevealed = onFinalPriceRevealed,
            Parent = parent
        }

        binAdd(ui)

        return binEmpty
    end, ANCESTORS)
end

return PriceRevealDisplay