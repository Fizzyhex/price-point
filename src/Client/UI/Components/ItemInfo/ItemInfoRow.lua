local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Children = Fusion.Children

local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)

local STRIPPED_PROPS = {"TextScaling", "Key", "Value"}

local function ItemInfoRow(props)
    local itemInfoRow = New "Frame" {
        Name = "ItemInfoRow",
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(1, 0),

        [Children] = {
            Label {
                Name = "Key",
                TextSize = ThemeProvider:GetFontSize("body", props.TextScaling),
                FontFace = ThemeProvider:GetFontFace("medium"),
                Text = Unwrap(props.Key),
            },

            Label {
                Name = "Value",
                Position = UDim2.fromScale(1, 0),
                AnchorPoint = Vector2.new(1, 0),
                TextSize = ThemeProvider:GetFontSize("body", props.TextScaling),
                Text = Unwrap(props.Value)
            }
        }
    }

    return Hydrate(itemInfoRow)(StripProps(props, STRIPPED_PROPS))
end

return ItemInfoRow