local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)

return function(target: Instance)
    local story = Nest {
        Parent = target,

        [Children] = {
            Label {
                Text = "This is how text labels will look normally."
            },

            Label {
                TextScaling = "cinema",
                Text = "This is how text labels will look with 'cinema' TextScaling."
            },

            VerticalListLayout {}
        }
    }

    return function()
        story:Destroy()
    end
end