local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Client.UI.Components.Button)
local Valueify = require(ReplicatedStorage.Client.UI.Util.Valueify)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local PropsUtil = require(ReplicatedStorage.Client.UI.Util.PropsUtil)
local HorizontalListLayout = require(ReplicatedStorage.Client.UI.Components.HorizontalListLayout)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local ForPairs = Fusion.ForPairs
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value
local Computed = Fusion.Computed
local New = Fusion.New
local Children = Fusion.Children
local Spring = Fusion.Spring

local STRIPPED_PROPS = { "CurrentSelection", "Options" }

local function ToggleGroup(props)
    local currentSelection = Valueify(props.CurrentSelection) or Value(Unwrap(props.Options)[1])
    local patchedProps = PropsUtil.PatchProps({
        Name = "ToggleGroup",
        AutomaticSize = Enum.AutomaticSize.XY,
        BackgroundColor3 = ThemeProvider:GetColor("background_2"),

        [Children] = {
            ForPairs(props.Options, function(index, option)
                local id, displayName = next(option)

                return index, Button {
                    Text = displayName,
                    Size = UDim2.fromOffset(150, 0),
                    IsActive = Computed(function()
                        return currentSelection:get() == id
                    end),

                    BackgroundColor3 = Spring(Computed(function()
                        if currentSelection:get() == id then
                            return ThemeProvider:GetColor("accent"):get()
                        else
                            return ThemeProvider:GetColor("background_3"):get()
                        end
                    end), 30),

                    TextColor3 = Spring(Computed(function()
                        if currentSelection:get() == id then
                            return ThemeProvider:GetColor("accent_contrast_body"):get()
                        else
                            return ThemeProvider:GetColor("body"):get()
                        end
                    end), 30),

                    [OnEvent "MouseButton1Click"] = function()
                        currentSelection:set(id)
                    end
                }
            end, Fusion.cleanup),

            New "UICorner" {
                CornerRadius = UDim.new(0, 12)
            },

            HorizontalListLayout { Padding = UDim.new(0, 8) },
            ShorthandPadding { Padding = UDim.new(0, 8) }
        }
    }, PropsUtil.StripProps(props, STRIPPED_PROPS))

    return New("Frame")(patchedProps)
end

return ToggleGroup