local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Hydrate = Fusion.Hydrate
local OnEvent = Fusion.OnEvent

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)

local STRIPPED_PROPS = { "OnClick" }

local function Button(props)
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
                Padding = UDim.new(0, 12)
            }
        },
    }

    return Hydrate(textButton)(StripProps(props, STRIPPED_PROPS))
end

return Button