local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value
local Cleanup = Fusion.Cleanup

local Timer = require(ReplicatedStorage.Client.UI.Components.Timer)

return function(target: Instance)
    local duration = 10
    local start = tick()
    local timeRemaining = Value()
    local timerConnection = RunService.Heartbeat:Connect(function()
        timeRemaining:set(math.max(duration - (tick() - start), 0))
    end)

    local story = Timer {
        Time = timeRemaining,
        UrgencyStart = 5,
        Parent = target,
        [Cleanup] = { timerConnection }
    }

    return function()
        story:Destroy()
    end
end