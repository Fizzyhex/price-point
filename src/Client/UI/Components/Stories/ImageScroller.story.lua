local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local ImageScroller = require(ReplicatedStorage.Client.UI.Components.ImageScroller)

return function(target: Instance)
    local story = Background {
        Parent = target,
        ClipsDescendants = true,

        [Children] = {
            ImageScroller {
                Image = "rbxassetid://13620494220",
                ImageColor3 = Color3.new(0.7, 0.7, 0.7),
                Position = UDim2.fromScale(0.5, 0.5),
                TileSize = UDim2.new(0, 60, 0, 60),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.fromScale(2, 2),
                Velocity = Vector2.new(40, 40)
            },

            ImageScroller {
                Image = "rbxassetid://13620494220",
                Position = UDim2.fromScale(0.5, 0.5),
                TileSize = UDim2.new(0, 80, 0, 80),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.fromScale(2, 2),
                Velocity = Vector2.new(50, 50)
            },
        }
    }

    return function()
        story:Destroy()
    end
end