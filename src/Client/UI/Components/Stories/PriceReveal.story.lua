local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local PriceReveal = require(ReplicatedStorage.Client.UI.Components.PriceReveal)
local Signal = require(ReplicatedStorage.Packages.Signal)

return function(target: Instance)
    local playEvent = Signal.new()
    local endEvent = Signal.new()

    local story = PriceReveal {
        PlayEvent = playEvent,
        EndEvent = endEvent,
        Parent = target,
    }

    playEvent:Fire(300)

    task.delay(6.5, function()
        endEvent:Fire()
    end)

    return function()
        story:Destroy()
    end
end