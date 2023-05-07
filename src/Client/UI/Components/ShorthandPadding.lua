local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate

local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)

local STRIPPED_PROPS = {"Padding"}

local function ShorthandPadding(props)
    local padding = New "UIPadding" {
        Name = "ShorthandPadding",
        PaddingTop = props.Padding,
        PaddingBottom = props.Padding,
        PaddingLeft = props.Padding,
        PaddingRight = props.Padding
    }

    return Hydrate(padding)(StripProps(props, STRIPPED_PROPS))
end

return ShorthandPadding