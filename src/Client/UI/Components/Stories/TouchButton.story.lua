local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local TouchButton = require(ReplicatedStorage.Client.Observers.TouchButton)

return function(target: Instance)
    local story = Nest {
        Parent = target,

        [Children] = {
            TouchButton {
                Text = "Boost"
            },

            VerticalListLayout { Padding = UDim.new(0, 16) },
            ShorthandPadding { Padding = UDim.new(0, 8) },
        }
    }

    return function()
        story:Destroy()
    end
end