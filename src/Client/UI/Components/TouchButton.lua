local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local New = Fusion.New
local Children = Fusion.Children
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent

local BUTTON_IMAGE = "rbxassetid://13710403736"

local function EmptyFunction() end

local function TouchButton(props)
    local enabled = props.Enabled or Value(true)
    local scale = props.Scale or Value(1)
    local isHeld = Value(false)
    local text = props.Text

    local function OnPress()
        print("press")
        isHeld:set(true)

        if props.OnPress then
            props.OnPress()
        end
    end

    local function OnRelease()
        isHeld:set(false)

        if props.OnRelease then
            props.OnRelease()
        end
    end

    return New "TextButton" {
        Name = props.Name or "TouchButton",
        Parent = props.Parent,
        Size = props.Size or UDim2.fromOffset(200, 200),
        BackgroundTransparency = 1,

        [OnEvent "MouseButton1Click"] =  props.OnActivate or EmptyFunction,
        [OnEvent "MouseButton1Down"] = OnPress,
        [OnEvent "MouseButton1Up"] = OnRelease,
        [OnEvent "MouseLeave"] = OnRelease,

        [Children] = {
            Nest {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),

                [Children] = {
                    New "ImageLabel" {
                        Name = "BackgroundImage",
                        Image = BUTTON_IMAGE,
                        Size = UDim2.fromScale(1, 1),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0.5, 0.5),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        ImageTransparency = 0.05,
                        ImageColor3 = Spring(Computed(function()
                            local color =
                                if isHeld:get()
                                then ThemeProvider:GetColor("background_2")
                                else ThemeProvider:GetColor("background")
                            return color:get()
                        end), 30),
                    },

                    New "UIScale" {
                        Scale = Spring(Computed(function()
                            if isHeld:get() then
                                return Unwrap(scale) * 1.1
                            end

                            return if Unwrap(enabled) then Unwrap(scale) else 0
                        end), 25)
                    },

                    Nest {
                        Name = "PaddedContent",

                        [Children] = {
                            New "ImageLabel" {
                                BackgroundTransparency = 1,
                                Image = props.Image or "",
                                Size = UDim2.fromScale(1, 1),
                            },

                            Label {
                                BackgroundTransparency = 1,
                                Text = text,
                                Size = UDim2.fromScale(1, 1),
                                Position = UDim2.fromScale(0.5, 0.5),
                                AnchorPoint = Vector2.new(0.5, 0.5),
                            },

                            ShorthandPadding { Padding = UDim.new(0, 12) }
                        }
                    }
                }
            }
        }
    }
end

return TouchButton