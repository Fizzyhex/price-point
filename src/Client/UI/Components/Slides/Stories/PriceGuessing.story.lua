local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PriceGuessing = require(ReplicatedStorage.Client.UI.Components.Slides.PriceGuessing)

return function(target: Instance)
    local story = PriceGuessing {
        ProductName = "Seal (0 braincells)",
        ProductImage = "rbxthumb://type=Asset&id=8657555135&w=420&h=420",

        Parent = target
    }

    return function()
        story:Destroy()
    end
end