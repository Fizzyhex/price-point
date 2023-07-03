local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AvatarItemCard = require(ReplicatedStorage.Client.UI.Components.AvatarItemCard)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local Value = Fusion.Value

return function(target: Instance)
    local story = Nest {
        Parent = target,

        [Children] = {
            AvatarItemCard {
                Parent = target,
                Image = "rbxthumb://type=Asset&id=10472779&w=420&h=420",
                Action = Value("purchase"),
                Name = "TestItem",
                Price = 50
            },

            AvatarItemCard {
                Parent = target,
                Image = "rbxthumb://type=Asset&id=10472779&w=420&h=420",
                Action = Value("equip"),
                Name = "TestItem",
                Price = 50000000
            },

            AvatarItemCard {
                Parent = target,
                Image = "rbxthumb://type=Asset&id=17237662&w=420&h=420",
                Action = Value("unavailable"),
                Name = "Some item with an insanely long name for no reason",
                Price = 85
            },


            VerticalListLayout { Padding = UDim.new(0, 12) },
            ShorthandPadding { Padding = UDim.new(0, 12) },
        }
    }

    return function()
        story:Destroy()
    end
end