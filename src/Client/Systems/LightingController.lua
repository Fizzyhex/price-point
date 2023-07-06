local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate
local Out = Fusion.Out

local colorBlends = {
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 222, 255)),
    ColorSequenceKeypoint.new(5, Color3.fromRGB(220, 222, 255)),
    ColorSequenceKeypoint.new(13, Color3.fromRGB(197, 197, 197)),
    ColorSequenceKeypoint.new(24, Color3.fromRGB(220, 222, 255)),
}

local function GetSequenceValue(keypoints, value)
    local lowest, highest

    for _, keypoint in keypoints do
        if keypoint.Time == value then
            return keypoint.Value
        end

        local distance = math.abs(keypoint.Time - value)
        local lowestDistance = lowest and math.abs(lowest.Time - value)
        local highestDistance = highest and math.abs(highest.Time - value)

        if keypoint.Time < value and lowest == nil or lowestDistance > distance then
            lowest = keypoint
        elseif keypoint.Time > value and highest == nil or highestDistance > distance then
            highest = keypoint
        end
    end

    if lowest and highest then
        return lowest.Value:Lerp(highest.Value, lowest.Time / highest.Time)
    else
        return if lowest then lowest.Value elseif highest then highest.Value else nil
    end
end

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
            return GetSequenceValue(colorBlends, clockTime:get())
            --return if isDark:get() then Color3.fromRGB(220, 222, 255) else Color3.fromRGB(197, 197, 197)
        end), 2),

        Decay = Spring(Computed(function()
            return if isDark:get() then Color3.fromRGB(125, 212, 255) else Color3.fromRGB(230, 189, 142)
        end), 2)
    }
end

return LightingController