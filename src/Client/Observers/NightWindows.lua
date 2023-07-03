local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local COLOR1 = Color3.fromRGB(222, 245, 255)
local COLOR2 = Color3.fromRGB(42, 32, 24)
local RANDOM = Random.new()
local TAG = "NightWindows"

local function MultiplyColor(color: Color3, amount: number)
    return Color3.new(color.R * amount, color.B * amount, color.G * amount)
end

-- Lights up windows when it's dark
local function NightWindows()
    local clockTime = Fusion.Value(0)
    local isDark = Fusion.Computed(function()
        return clockTime:get() >= 17.8 or clockTime:get() <= 2
    end)

    Fusion.Hydrate(Lighting) {
        [Fusion.Out "ClockTime"] = clockTime
    }

    local function GetBaseColor(texture: Texture)
        local baseColor = texture.Parent:GetAttribute("BaseColor")

        if not baseColor then
            baseColor = COLOR1:Lerp(COLOR2, RANDOM:NextNumber())
            texture.Parent:SetAttribute("BaseColor", baseColor)
        end

        return baseColor
    end

    local function Update(texture: Texture)
        texture.Color3 = if isDark:get() then MultiplyColor(GetBaseColor(texture), 10) else Color3.new(1, 1, 1)
    end

    Fusion.Observer(isDark):onChange(function()
        print("isdark", isDark:get())
        for _, tagged in CollectionService:GetTagged(TAG) do
            Update(tagged)
        end
    end)

    Observers.observeTag(TAG, function(texture: Texture)
        if texture:IsA("Texture") == false and texture:IsA("Decal") == false then
            warn(`{texture:GetFullName()} is mistagged with {TAG}!`)
            CollectionService:RemoveTag(texture, TAG)
            return function() end
        end

        Update(texture)
        return function() end
    end, { workspace })
end

return NightWindows