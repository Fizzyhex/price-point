local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Computed = Fusion.Computed

-- An ImageLabel that changes colour based on the current theme.
local function Icon(props)
    local icon = New "ImageLabel" {
        Name = "Icon",
        BackgroundTransparency = 1,
        ImageColor3 = ThemeProvider:GetColor("body"),
        ScaleType = Enum.ScaleType.Fit
    }

    return Hydrate(icon)(props)
end

return Icon