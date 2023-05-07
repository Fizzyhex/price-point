local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local New = Fusion.New
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)

local STRIPPED_PROPS = { "TextScaling" }

local function Header(props)
    local header = New "TextLabel" {
        Name = "Header",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.XY,
        FontFace = ThemeProvider:GetFontFace("header"),
        TextSize = ThemeProvider:GetFontSize("header", props.TextScaling),
        TextColor3 = ThemeProvider:GetColor("header"),
    }

    return Hydrate(header)(StripProps(props, STRIPPED_PROPS))
end

return Header