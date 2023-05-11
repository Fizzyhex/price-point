local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local Hydrate = Fusion.Hydrate

local ANCESTORS = { workspace }

local function UIThemeColor()
    return Observers.observeTag("UIThemeColor", function(instance: Instance)
        local property = "Color"

        if instance:IsA("GuiObject") then
            property = "BackgroundColor3"
        end

        local originalColor = instance[property]

        Hydrate(instance) {
            [property] = ThemeProvider:GetColor("background")
        }

        return function()
            instance[property] = originalColor
        end
    end, ANCESTORS)
end

return UIThemeColor