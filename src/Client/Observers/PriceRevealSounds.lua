local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Red = require(ReplicatedStorage.Packages.Red)
local GameStateChannel = require(ReplicatedStorage.Client.EventChannels.GameStateChannel)

local ANCESTORS = { workspace }

local function PriceRevealSounds()
    return Observers.observeTag("PriceRevealSounds", function(part: BasePart)
        local revealSound: Sound = part:WaitForChild("RevealSound")
        local binAdd, binEmpty = Red.Bin()

        binAdd(GameStateChannel.ObservePriceRevealed(function()
            revealSound:Play()
        end))

        return function()
            binEmpty()
        end
    end, ANCESTORS)
end

return PriceRevealSounds