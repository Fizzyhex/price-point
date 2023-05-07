local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local Hydrate = Fusion.Hydrate
local New = Fusion.New
local Computed = Fusion.Computed

local ProductImageCard = require(ReplicatedStorage.Client.UI.Components.ProductImageCard)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local HorizontalListLayout = require(ReplicatedStorage.Client.UI.Components.HorizontalListLayout)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)

local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)

local STRIPPED_PROPS = {
    "ProductName",
    "ProductImage",
    "TextScaling"
}

local function PriceGuessing(props)
    local textScaling = props.TextScaling

    local component = Background {
        Name = "PriceGuessing",
        BackgroundColor3 = Color3.new(1, 1, 1),

        [Children] = {
            New "UIGradient" {
                Color = Computed(function()
                    local color1 = Unwrap(ThemeProvider:GetColor("background"))
                    local color2 = Unwrap(ThemeProvider:GetColor("background_3"))

                    return ColorSequence.new(color1, color2)
                end),
                Rotation = -45
            },

            Background {
                Name = "Header",
                LayoutOrder = 0,
                BackgroundColor3 = ThemeProvider:GetColor("background_3"),
                Size = UDim2.new(1, 0, 0, 80),

                [Children] = {
                    Header {
                        Text = props.ProductName,
                        TextScaled = true,
                        TextScaling = textScaling
                    },
                    ShorthandPadding { Padding = UDim.new(0, 12) }
                }
            },

            Nest {
                LayoutOrder = 1,
                Size = UDim2.new(1, 0, 1, -80),

                [Children] = {
                    Nest {
                        LayoutOrder = 0,
                        Size = UDim2.new(1, -300, 1, 0),

                        [Children] = {
                            ProductImageCard {
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Image = props.ProductImage,
                                SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                Size = UDim2.new(1, 0, 1, 0),
                            },

                            ShorthandPadding { Padding = UDim.new(0.15, 0) }
                        }
                    },

                    Background {
                        Name = "Details",
                        BackgroundColor3 = ThemeProvider:GetColor("background_2"),
                        LayoutOrder = 1,
                        Size = UDim2.new(0, 300, 1, 0),

                        [Children] = {
                            ShorthandPadding { Padding = UDim.new(0, 12) }
                        }
                    },

                    HorizontalListLayout {}
                }
            },

            VerticalListLayout {}
        }
    }

    return Hydrate(component)(StripProps(props, STRIPPED_PROPS))
end

return PriceGuessing