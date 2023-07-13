local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate
local Out = Fusion.Out

local colorBlends = {
    ColorSequenceKeypoint.new(3, Color3.fromRGB(130, 190, 255)),
    ColorSequenceKeypoint.new(5, Color3.fromRGB(207, 186, 228)),
    ColorSequenceKeypoint.new(13, Color3.fromRGB(153, 206, 255)),
    ColorSequenceKeypoint.new(17.5, Color3.fromRGB(153, 206, 255)),--ColorSequenceKeypoint.new(17.5, Color3.fromRGB(255, 166, 41)),
    ColorSequenceKeypoint.new(22, Color3.fromRGB(165, 208, 255)),
}

local decayBlends = {
    ColorSequenceKeypoint.new(3, Color3.fromRGB(156, 130, 213)),
    ColorSequenceKeypoint.new(5, Color3.fromRGB(255, 168, 110)),
    ColorSequenceKeypoint.new(13, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(17.5, Color3.fromRGB(255, 255, 255)),--ColorSequenceKeypoint.new(17.5, Color3.fromRGB(213, 127, 88)),
    ColorSequenceKeypoint.new(22, Color3.fromRGB(156, 130, 213)),
}

local glareBlends = {
    NumberSequenceKeypoint.new(3, 1),
    NumberSequenceKeypoint.new(5, 0.3),
    NumberSequenceKeypoint.new(13, 0.25),
    NumberSequenceKeypoint.new(17.5, 0.15),
    NumberSequenceKeypoint.new(22, 1),
}

local hazeBlends = {
    NumberSequenceKeypoint.new(3, 0.8),
    NumberSequenceKeypoint.new(5, 1),
    NumberSequenceKeypoint.new(13, 0.6),
    NumberSequenceKeypoint.new(17.5, 3),
    NumberSequenceKeypoint.new(22, 0.6),
}

local function Lerp(a, b, t)
	return a + (b - a) * t
end

local function GetSequenceValue(keypoints, value)
    local lowest, highest

    for _, keypoint in keypoints do
        if keypoint.Time == value then
            return keypoint.Value
        end

        local distance = math.abs(keypoint.Time - value)
        local lowestDistance = lowest and math.abs(lowest.Time - value)
        local highestDistance = highest and math.abs(highest.Time - value)

        if keypoint.Time < value and (lowest == nil or lowestDistance > distance) then
            lowest = keypoint
        elseif keypoint.Time > value and (highest == nil or highestDistance > distance) then
            highest = keypoint
        end
    end

    if lowest and highest then
        if typeof(lowest.Value) == "number" then
            return Lerp(lowest.Value, highest.Value, lowest.Time / highest.Time)
        else
            return lowest.Value:Lerp(highest.Value, lowest.Time / highest.Time)
        end
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
        Color = Spring(Computed(function()
            return GetSequenceValue(colorBlends, clockTime:get())
        end), 2),

        Decay = Spring(Computed(function()
            return GetSequenceValue(decayBlends, clockTime:get())
        end), 2),

        Haze = Spring(Computed(function()
            return GetSequenceValue(hazeBlends, clockTime:get())
        end), 2),

        Glare = Spring(Computed(function()
            return GetSequenceValue(glareBlends, clockTime:get())
        end), 2)
    }
end

return LightingController