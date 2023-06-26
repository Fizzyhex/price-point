local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Observers = require(ReplicatedStorage.Packages.Observers)

local function ClockTimeAnimator()
    local clockTime = Fusion.Value(Lighting.TimeOfDay)
    local timeSpring = Fusion.Spring(clockTime, 5)

    local stopObserver = Observers.observeAttribute(Lighting, "ServerTime", function(value: number)
        clockTime:set(value)
    end)

    Fusion.Hydrate(Lighting) {
        ClockTime = timeSpring
    }

    return stopObserver
end

return ClockTimeAnimator