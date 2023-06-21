local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local PropsUtil = require(ReplicatedStorage.Client.UI.Util.PropsUtil)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local Valueify = require(ReplicatedStorage.Client.UI.Util.Valueify)
local New = Fusion.New
local Value = Fusion.Value
local Children = Fusion.Children
local Out = Fusion.Out
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup
local Spring = Fusion.Spring

local STRIPPED_PROPS = { "Output", "Range" }

local function HorizontalSlider(props)
    local output = props.Output or Value(0)
    local barAbsolutePosition = Value(Vector2.zero)
    local barAbsoluteSize = Value(Vector2.zero)
    local inputPosition = Value(nil)
    local range = Valueify(props.Range or NumberRange.new(0, 100))
    local barEndPosition = Computed(function()
        if barAbsolutePosition:get() == nil or barAbsoluteSize:get() == nil then
            return Vector2.zero
        end

        return barAbsolutePosition:get() + Vector2.new(barAbsoluteSize:get().X, 0)
    end)
    local percentage = Computed(function()
        local min, max = range:get().Min, range:get().Max

        if inputPosition:get() and barAbsolutePosition:get() and barAbsoluteSize:get() then
            local relative = inputPosition:get() - barAbsolutePosition:get()
            local newPercentage = math.clamp(relative.X / barAbsoluteSize:get().X, 0, 1)
            output:set(((max - min) * newPercentage) + min)
            return newPercentage
        else
            return output:get() / (max - min)
        end
    end)
    local percentageSpring = Spring(percentage, 20, 0.7)
    local inUse = Value(false)
    local inputBinAdd, inputBinEmpty = Bin()

    local function OnInputChanged(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement and inUse:get() then
            inputPosition:set(Vector2.new(input.Position.X, input.Position.Y))
        end
    end

    local function OnInputBegan(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            inUse:set(true)
            inputPosition:set(Vector2.new(input.Position.X, input.Position.Y))
        end
    end

    local function OnInputEnded(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            inUse:set(false)
        end
    end

    local function OnInUseChanged()
        if inUse:get() then
            inputBinAdd(UserInputService.InputChanged:Connect(OnInputChanged))
            inputBinAdd(UserInputService.InputEnded:Connect(OnInputEnded))
        else
            inputBinEmpty()
        end
    end

    local inUseObserver = Observer(inUse):onChange(OnInUseChanged)
    OnInUseChanged()

    local patchedProps = PropsUtil.PatchProps({
        Name = "HorizontalSlider",
        Active = true,
        BackgroundColor3 = ThemeProvider:GetColor("background_3"),
        [OnEvent "InputChanged"] = OnInputChanged, -- For Hoarcekat
        [OnEvent "InputBegan"] = OnInputBegan,

        [Cleanup] = { inUseObserver, inputBinEmpty },
        [Children] = {
            Nest {
                [Out "AbsolutePosition"] = barAbsolutePosition,
                [Out "AbsoluteSize"] = barAbsoluteSize,
                
                [Children] = {
                    New "Frame" {
                        Name = "Shadow",
                        Size = UDim2.fromScale(1, 1),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        BackgroundTransparency = 0.8,
                        ZIndex = 2,

                        [Children] = {
                            New "UICorner" {
                                CornerRadius = UDim.new(1, 0)
                            },

                            New "UIGradient" {
                                Rotation = 90,
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0),
                                    NumberSequenceKeypoint.new(0.4, 1),
                                    NumberSequenceKeypoint.new(1, 1)
                                })
                            }
                        }
                    },

                    New "Frame" {
                        Name = "Nob",
                        Active = true,
                        BackgroundColor3 = ThemeProvider:GetColor("accent"),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = Computed(function()
                            return UDim2.fromScale(math.clamp(percentageSpring:get(), 0, 1), 0.5)
                        end),
                        Size = UDim2.new(1, 4, 1, 4),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                        ZIndex = 3,
                        [OnEvent "InputBegan"] = OnInputBegan,

                        [Children] = {
                            New "UICorner" {
                                CornerRadius = UDim.new(1, 0)
                            },

                            New "UIStroke" {
                                Thickness = 4,
                                Color = ThemeProvider:GetColor("background_3")
                            },
                        }
                    },

                    New "Frame" {
                        Name = "Bar",
                        Active = true,
                        BackgroundColor3 = ThemeProvider:GetColor("accent"),
                        Size = Computed(function()
                            -- Might have to use a UIGradient instead for when this is rounded
                            return UDim2.fromScale(math.clamp(percentageSpring:get(), 0, 1), 1)
                        end),

                        [Children] = {
                            New "UICorner" {
                                CornerRadius = UDim.new(1, 0)
                            },

                            New "UIGradient" {
                                Rotation = 90,
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0),
                                    NumberSequenceKeypoint.new(0.35, 0),
                                    NumberSequenceKeypoint.new(1, 0.1)
                                })
                            }
                        }
                    },
                }
            },

            New "UICorner" {
                CornerRadius = UDim.new(1, 0)
            },
        }
    }, PropsUtil.StripProps(props, STRIPPED_PROPS))

    return New("Frame")(patchedProps)
end

return HorizontalSlider