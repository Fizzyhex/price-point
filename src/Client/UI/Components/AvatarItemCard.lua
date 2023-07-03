local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local IconContainer = require(ReplicatedStorage.Client.UI.Components.IconContainer)
local Icon = require(ReplicatedStorage.Client.UI.Components.Icon)
local PropsUtil = require(ReplicatedStorage.Client.UI.Util.PropsUtil)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local HorizontalListLayout = require(ReplicatedStorage.Client.UI.Components.HorizontalListLayout)
local Valueify = require(ReplicatedStorage.Client.UI.Util.Valueify)
local PrimaryButton = require(ReplicatedStorage.Client.UI.Components.PrimaryButton)
local Button = require(ReplicatedStorage.Client.UI.Components.Button)
local NumberUtil = require(ReplicatedStorage.Shared.Util.NumberUtil)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)

local PADDING = UDim.new(0, 12)
local ACTION_BUTTON_SIZE = UDim2.fromOffset(100, 0)
local STRIPPED_PROPS = { "Image", "Price", "Name", "Action", "OnActionClicked" }
local ACTION_BUTTON_KEY = {
    equip = "Equip",
    unequip = "Unequip",
    wear = "Wear"
}

local function AvatarItemCard(props)
    local action = if props.Action then Valueify(props.Action) else Value("equip")

    local cardProps = {
        Name = "AvatarItemCard",
        Size = UDim2.fromOffset(500, 0),
        BackgroundColor3 = ThemeProvider:GetColor("background"),
        AutomaticSize = Enum.AutomaticSize.XY,

        [Children] = {
            Nest {
                [Children] = {
                    New "ImageLabel" {
                        Name = "ItemIcon",
                        BackgroundTransparency = 1,
                        Image = props.Image,
                        ScaleType = Enum.ScaleType.Fit,
                        Size = UDim2.fromOffset(100, 80)
                    },

                    Nest {
                        Size = UDim2.fromScale(0, 0),
                        AutomaticSize = Enum.AutomaticSize.XY,
                        Position = UDim2.fromOffset(50 + PADDING.Offset, 0),

                        [Children] = {
                            Label {
                                Name = "NameLabel",
                                Text = props.Name,
                                AutomaticSize = Enum.AutomaticSize.Y,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                TextTruncate = Enum.TextTruncate.AtEnd,
                                Size = UDim2.fromOffset(260, 0)
                            },

                            IconContainer {
                                Size = UDim2.fromScale(1, 0),
                                Icon = Icon { Image = "rbxassetid://13480760066" },
                                Label = Label {
                                    Text = Computed(function()
                                        local price = Unwrap(props.Price) or 0
                                        return NumberUtil.CommaSeperate(price)
                                    end),
                                },
                            },

                            VerticalListLayout {}
                        }
                    },

                    HorizontalListLayout { Padding = PADDING },
                },
            },

            Label {
                Text = "Unavailable",
                TextTransparency = 0.3,
                Position = UDim2.fromScale(1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Visible = Computed(function()
                    return action:get() == "unavailable"
                end)
            },

            PrimaryButton {
                Text = "Purchase",
                Position = UDim2.fromScale(1, 0),
                Size = ACTION_BUTTON_SIZE,
                AnchorPoint = Vector2.new(1, 0),
                Visible = Computed(function()
                    return action:get() == "purchase"
                end),
                OnClick = props.OnActionClicked
            },

            Button {
                Text = Computed(function()
                    return ACTION_BUTTON_KEY[action:get()] or ""
                end),
                BackgroundColor3 = ThemeProvider:GetColor("background_3"),
                TextColor3 = ThemeProvider:GetColor("body"),
                Size = ACTION_BUTTON_SIZE,
                Position = UDim2.fromScale(1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Visible = Computed(function()
                    return action:get() == "equip" or action:get() == "unequip" or action:get() == "wear"
                end),
                OnClick = props.OnActionClicked
            },

            New "UICorner" {
                CornerRadius = UDim.new(0, 12)
            },

            ShorthandPadding { Padding = PADDING }
        }
    }

    return New("Frame")(
        PropsUtil.PatchProps(
            cardProps,
            PropsUtil.StripProps(props, STRIPPED_PROPS)
        )
    )
end

return AvatarItemCard