local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate

local function HorizontalListLayout(props)
    local listLayout = New "UIListLayout" {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder
    }

    return Hydrate(listLayout)(props)
end

return HorizontalListLayout