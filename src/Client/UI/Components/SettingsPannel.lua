local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Backplate = require(ReplicatedStorage.Client.UI.Components.Backplate)
local Header = require(ReplicatedStorage.Client.UI.Components.Header)

local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local HorizontalSlider = require(ReplicatedStorage.Client.UI.Components.HorizontalSlider)
local ToggleGroup = require(ReplicatedStorage.Client.UI.Components.ToggleGroup)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local HorizontalListLayout = require(ReplicatedStorage.Client.UI.Components.HorizontalListLayout)
local PropsUtil = require(ReplicatedStorage.Client.UI.Util.PropsUtil)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local Cleanup = Fusion.Cleanup
local Spring = Fusion.Spring

local STRIPPED_PROPS = { "Settings" }
local CAMERA = workspace.CurrentCamera

local function SettingsPannel(props)
    local settingsArray = props.Settings
    local strippedProps = PropsUtil.StripProps(props, STRIPPED_PROPS)
    local viewportSize = Value(CAMERA.ViewportSize)
    local isPortraitMode = Value(false)

    local function OnViewportSizeChanged()
        viewportSize:set(CAMERA.ViewportSize)
        isPortraitMode:set(viewportSize:get().X <= 380)
    end

    OnViewportSizeChanged()

    local backplateProps = {
        AutomaticSize = Computed(function()
            return if isPortraitMode:get() then Enum.AutomaticSize.Y else Enum.AutomaticSize.XY
        end),

        Size = Spring(Computed(function()
            return if isPortraitMode:get() then UDim2.new(1, -12, 0, 0) else UDim2.fromScale(0, 0)
        end), 20, 0.9),

        [Cleanup] = {
            CAMERA:GetPropertyChangedSignal("ViewportSize"):Connect(OnViewportSizeChanged)
        },
        [Children] = {
            New "UIStroke" {
                Thickness = 4,
                Color = ThemeProvider:GetColor("accent")
            },

            Header { Text = "Settings" },
            ForValues(settingsArray, function(setting)
                local component

                if setting.type == "NumberRange" then
                    component = HorizontalSlider {
                        Size = UDim2.fromOffset(300, 20),
                        Output = setting.value,
                        Range = NumberRange.new(setting.min, setting.max)
                    }
                elseif setting.type == "Toggle" then
                    component = ToggleGroup {
                        Size = UDim2.fromOffset(300, 0),
                        CurrentSelection = setting.value,
                        Options = assert(setting.options, `Setting "{setting.id}" is missing options`)
                    }
                end

                return New "Frame" {
                    Name = "SettingContainer",
                    LayoutOrder = setting.layoutOrder,
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = UDim2.fromOffset(0, 50),

                    [Children] = {
                        Label {
                            Size = UDim2.fromOffset(150, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Text = Unwrap(setting.displayName or setting.id)
                        },
                        component,
                        HorizontalListLayout {
                            Padding = UDim.new(0, 8),
                            FillDirection = Computed(function()
                                return if isPortraitMode:get() then Enum.FillDirection.Vertical else Enum.FillDirection.Horizontal
                            end),
                            VerticalAlignment = Enum.VerticalAlignment.Center
                        }
                    }
                }
            end, Fusion.cleanup),

            VerticalListLayout { Padding = UDim.new(0, 12) },
            ShorthandPadding { Padding = UDim.new(0, 24) }
        }
    }

    return Backplate(PropsUtil.PatchProps(backplateProps, strippedProps))
end

return SettingsPannel