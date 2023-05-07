local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local New = Fusion.New
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)

local STRIPPED_PROPS = { "TextScaling" }

local function Label(props)
    local label = New "TextLabel" {
        Name = "Label",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        FontFace = ThemeProvider:GetFontFace("body"),
        TextSize = ThemeProvider:GetFontSize("body", props.TextScaling),
        TextColor3 = ThemeProvider:GetColor("body"),
    }

    return Hydrate(label)(StripProps(props, STRIPPED_PROPS))
end

return Label