local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvatarItemCard = require(ReplicatedStorage.Client.UI.Components.AvatarItemCard)

return function(target: Instance)
    local story = AvatarItemCard {
        Parent = target,
        Id = 10472779,
        AvatarItemType = Enum.AvatarItemType.Asset,
        Size = UDim2.new(0, 500, 0, 100)
    }

    return function()
        story:Destroy()
    end
end