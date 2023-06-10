local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Hydrate = Fusion.Hydrate
local OnEvent = Fusion.OnEvent
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)

local STRIPPED_PROPS = { "OnClick", "IsHeld" }
local TEXT_PADDING = UDim.new(0, 12)

local function Button(props)
    local isHeld = props.IsHeld

    local textButton = New "TextButton" {
        AutoButtonColor = true,
        FontFace = props.Font or ThemeProvider:GetFontFace("body"),
        TextColor3 = props.Font or ThemeProvider:GetColor("body"),
        TextSize = props.TextSize or ThemeProvider:GetFontSize("body", props.TextScaling),
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
        TextWrapped = true,
        BackgroundColor3 = props.BackgroundColor3 or ThemeProvider:GetColor("background_3"),
        AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.XY,

        [OnEvent "MouseButton1Click"] = function()
            if props.OnClick then
                props.OnClick()
            end
        end,

        [Children] = {
            New "UICorner" {
                CornerRadius = UDim.new(0, 12)
            },

            ShorthandPadding {
                Padding = TEXT_PADDING
            },

            New "ImageLabel" {
                BackgroundTransparency = 1,
                Name = "Shadow",

                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromScale(1, 1) + (UDim2.fromOffset(TEXT_PADDING.Offset * 2, TEXT_PADDING.Offset * 2)),

                Image = "rbxassetid://13702420539",
                ImageColor3 = Color3.new(0, 0, 0),
                ImageTransparency = Computed(function()
                    return if Unwrap(isHeld) then 0.5 else 1
                end),

                [Children] = New "UICorner" {
                    CornerRadius = UDim.new(0, 12)
                },
            }
        },
    }

    return Hydrate(textButton)(StripProps(props, STRIPPED_PROPS))
end

return Button