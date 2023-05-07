local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local ItemInfo = require(ReplicatedStorage.Client.UI.Components.ItemInfo)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)

return function(target: Instance)
    local dimensions = UDim2.fromOffset(400, 0)
    local rows = {
        {Key = "Type", Value = "Accessory"},
        {Key = "Sales", Value = 20000},
        {Key = "On Sale", Value = "Yes"},
    }

    local story = Nest {
        Parent = target,
        [Children] = {
            ItemInfo {
                Size = dimensions,
                Rows = rows,
            },

            ItemInfo {
                Size = dimensions,
                TextScaling = "cinema",
                Rows = rows,
            },

            VerticalListLayout {}
        },
    }

    return function()
        story:Destroy()
    end
end