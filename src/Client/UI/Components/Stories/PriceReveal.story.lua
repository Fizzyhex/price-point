local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

    playEvent:Fire(math.random(0, 10000))

    task.delay(6.5, function()
        endEvent:Fire()
    end)

    return function()
        story:Destroy()
    end
end