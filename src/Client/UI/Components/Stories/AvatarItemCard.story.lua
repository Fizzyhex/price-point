local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvatarItemCard = require(ReplicatedStorage.Client.UI.Components.AvatarItemCard)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value

return function(target: Instance)
    local action = Value("purchase")

    local story = AvatarItemCard {
        Parent = target,
        Image = "rbxthumb://type=Asset&id=10472779&w=420&h=420",
        Action = action,
        Name = "TestItem",
        Price = 50
    }

    return function()
        story:Destroy()
    end
end