local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Hydrate = Fusion.Hydrate
local Value = Fusion.Value
local Out = Fusion.Out
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup
local Spring = Fusion.Spring
local Computed = Fusion.Computed

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)

local STRIPPED_PROPS = { "TextFilters" }

local function TextBox(props)
    local lastValidText = Value("")
    local text = Value("")
    local textFilters = props.TextFilters
    local invalidInputFlag = Value(false)
    local accentColor
    accentColor = Spring(Computed(function()
        if invalidInputFlag:get() then
            invalidInputFlag:set(false)
            accentColor:setPosition(Unwrap(ThemeProvider:GetColor("error")))
        end

        return Unwrap(ThemeProvider:GetColor("background_3"))
    end))

    local textObserver = Observer(text):onChange(function()
        local newText = text:get()
        local oldText = lastValidText:get()

        if newText == nil or #newText == 0 then
            return
        end

        if newText == oldText then
            return
        end

        local currentTextFilters = Unwrap(textFilters)

        if not currentTextFilters then
            return
        end

        for _, filter in currentTextFilters do
            if not filter(newText) then
                -- Revert to old text if the filter fails
                text:set(oldText)
                invalidInputFlag:set(true)
                return
            end
        end

        lastValidText:set(newText)
    end)

    local textBox = New "TextBox" {
        FontFace = props.Font or ThemeProvider:GetFontFace("body"),
        TextColor3 = props.Font or ThemeProvider:GetColor("body"),
        TextSize = props.TextSize or ThemeProvider:GetFontSize("body", props.TextScaling),
        TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left,
        TextTruncate = props.TextTruncate or Enum.TextTruncate.AtEnd,

        BackgroundColor3 = props.BackgroundColor3 or ThemeProvider:GetColor("background"),

        AutomaticSize = props.AutomaticSize or Enum.AutomaticSize.XY,
        Size = props.Size or UDim2.fromOffset(200, 0),

        -- Two-way binding
        Text = text,
        [Out "Text"] = text,

        [Children] = {
            New "UICorner" {
                CornerRadius = UDim.new(0, 12)
            },

            New "UIStroke" {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = accentColor,
                Thickness = 2
            },

            ShorthandPadding {
                Padding = UDim.new(0, 12)
            }
        },

        [Cleanup] = { textObserver }
    }

    return Hydrate(textBox)(StripProps(props, STRIPPED_PROPS))
end

return TextBox