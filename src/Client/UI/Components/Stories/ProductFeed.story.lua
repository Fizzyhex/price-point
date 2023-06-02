local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value

local AvatarItemFeed = require(ReplicatedStorage.Client.UI.Components.AvatarItemFeed)

return function(target: Instance)
    local story = AvatarItemFeed {
        Parent = target,
        Size = UDim2.new(1, 0, 1, -90),
        Products = Value({
            { id = 10472779, type = Enum.AvatarItemType.Asset },
            { id = 12221132031, type = Enum.AvatarItemType.Asset },
            { id = 589, type = Enum.AvatarItemType.Bundle }
        })
    }

    return function()
        story:Destroy()
    end
end