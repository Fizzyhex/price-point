local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local New = Fusion.New
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)

local function Background(props)
    local background = New "Frame" {
        Name = "Background",
        BackgroundColor3 = ThemeProvider:GetColor("background"),
        Size = UDim2.fromScale(1, 1)
    }

    return Hydrate(background)(props)
end

return Background