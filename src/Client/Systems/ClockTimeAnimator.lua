local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Observers = require(ReplicatedStorage.Packages.Observers)

local function ClockTimeAnimator()
    local clockTime = Fusion.Value(Lighting.TimeOfDay)
    local timeSpring = Fusion.Spring(clockTime, 5)

    Observers.observeAttribute(Lighting, "ServerTime", function(value: number)
        clockTime:set(value)
    end)

    Fusion.Observer(timeSpring):onChange(function()
        if timeSpring:get() >= 23.999 then
            clockTime:set(0)
            timeSpring:setPosition(0)
        end
    end)

    Fusion.Hydrate(Lighting) {
        ClockTime = timeSpring
    }
end

return ClockTimeAnimator