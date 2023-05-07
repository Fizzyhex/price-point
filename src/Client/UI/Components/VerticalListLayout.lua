local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate

local function VerticalListLayout(props)
    local listLayout = New "UIListLayout" {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder
    }

    return Hydrate(listLayout)(props)
end

return VerticalListLayout