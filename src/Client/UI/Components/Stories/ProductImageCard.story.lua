local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local ProductImageCard = require(ReplicatedStorage.Client.UI.Components.ProductImageCard)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)

return function(target: Instance)
    local story = Nest {
        Parent = target,

        [Children] = {
            ProductImageCard {
                Image = "rbxthumb://type=Asset&id=8657555135&w=420&h=420"
            }
        },
    }

    return function()
        story:Destroy()
    end
end