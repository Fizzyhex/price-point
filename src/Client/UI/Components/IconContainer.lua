local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local HorizontalListLayout = require(ReplicatedStorage.Client.UI.Components.HorizontalListLayout)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Children = Fusion.Children
local Value = Fusion.Value
local Out = Fusion.Out
local Computed = Fusion.Computed

local STRIPPED_PROPS = { "Icon", "Label" }

-- Creates a wrapper with an `Icon` that automatically matches the height of the `Label`
local function IconContainer(props)
    local icon = props.Icon
    local label = props.Label
    local labelAbsoluteSize = Value(nil)

    local ui = New "Frame" {
        Name = "IconContainer",

        [Children] = {
            Hydrate(icon) {
                Size = Computed(function()
                    if not labelAbsoluteSize:get() then
                        return UDim2.new()
                    end

                    return UDim2.new(0, labelAbsoluteSize:get().Y, 0, labelAbsoluteSize:get().Y)
                end)
            },

            Hydrate(label) {
                [Out "AbsoluteSize"] = labelAbsoluteSize,
            },

            HorizontalListLayout { Padding = UDim.new(0, 4) },
        }
    }

    return Hydrate(ui)(StripProps(props, STRIPPED_PROPS))
end

return IconContainer