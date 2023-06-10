local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local Hydrate = Fusion.Hydrate

local ANCESTORS = { workspace }

local function UIThemeColor()
    return Observers.observeTag("UIThemeColor", function(instance: Instance)
        local property = "Color"

        if instance:IsA("TextLabel") then
            property = "TextColor3"
        elseif instance:IsA("GuiObject") then
            property = "BackgroundColor3"
        elseif instance:IsA("Decal") or instance:IsA("Texture") then
            property = "Color3"
        end

        local originalColor = instance[property]
        local newColorName = instance:GetAttribute("UIThemeColor") or "background"

        Hydrate(instance) {
            [property] = ThemeProvider:GetColor(newColorName)
        }

        return function()
            instance[property] = originalColor
        end
    end, ANCESTORS)
end

return UIThemeColor