local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate
local Out = Fusion.Out

-- Controls lighting based on the current time
local function LightingController()
    local atmosphere: Atmosphere = Lighting:WaitForChild("Atmosphere")
    local clockTime = Fusion.Value(0)
    local isDark = Fusion.Computed(function()
        return clockTime:get() >= 17.8 or clockTime:get() <= 6.3
    end)

    Hydrate(Lighting) {
        [Out "ClockTime"] = clockTime
    }

    Hydrate(atmosphere) {
        Glare = Spring(Computed(function()
            return if isDark:get() then 0.5 else 0.3
        end), 2),

        Color = Spring(Computed(function()
            return if isDark:get() then Color3.fromRGB(220, 222, 255) else Color3.fromRGB(197, 197, 197)
        end), 2),

        Decay = Spring(Computed(function()
            return if isDark:get() then Color3.fromRGB(125, 212, 255) else Color3.fromRGB(230, 189, 142)
        end), 2)
    }
end

return LightingController