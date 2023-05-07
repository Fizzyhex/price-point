local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local New = Fusion.New
local ForPairs = Fusion.ForPairs
local Children = Fusion.Children
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)

local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local ItemInfoRow = require(script.ItemInfoRow)

local STRIPPED_PROPS = { "TextScaling", "Rows" }

local function ItemInfo(props)
    local itemInfo = Background {
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Size = UDim2.fromScale(1, 0),

        [Children] = {
            ForPairs(props.Rows, function(index, rowData)
                return index, ItemInfoRow {
                    TextScaling = props.TextScaling,
                    LayoutOrder = index,
                    Key = rowData.Key,
                    Value = rowData.Value,
                }
            end, Fusion.cleanup),

            VerticalListLayout {}
        }
    }

    return Hydrate(itemInfo)(StripProps(props, STRIPPED_PROPS))
end

return ItemInfo