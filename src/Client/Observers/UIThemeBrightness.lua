local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate

local ANCESTORS = { workspace }

local function UIThemeBrightness()
    print("loading uith")

    return Observers.observeTag("UIThemeBrightness", function(surfaceGui: SurfaceGui)
        Hydrate(surfaceGui) {
            Brightness = ThemeProvider:GetSurfaceGuiBrightness()
        }

        print("Hydrated", surfaceGui, "with", ThemeProvider:GetSurfaceGuiBrightness():get())

        return function()
            Hydrate(surfaceGui) {
                Brightness = surfaceGui.Brightness
            }
        end
    end, ANCESTORS)
end

return UIThemeBrightness