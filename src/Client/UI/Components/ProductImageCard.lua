local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Hydrate = Fusion.Hydrate

local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local ProductImage = require(ReplicatedStorage.Client.UI.Components.ProductImage)

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)

local STRIPPED_PROPS = { "Image", "ImageTransparency" }

local function ProductImageCard(props)
    local card = New "Frame" {
        Size = UDim2.fromOffset(200, 200),
        BackgroundColor3 = ThemeProvider:GetColor("background", "light"),

        [Children] = {
            ProductImage {
                Size = UDim2.fromScale(1, 1),
                Image = props.Image,
                ImageTransparency = props.ImageTransparency
            },

            New "UICorner" {
                CornerRadius = UDim.new(0, 24)
            },

            ShorthandPadding { Padding = UDim.new(0, 12) }
        }
    }

    return Hydrate(card)(StripProps(props, STRIPPED_PROPS))
end

return ProductImageCard