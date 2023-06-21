local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HorizontalSlider = require(ReplicatedStorage.Client.UI.Components.HorizontalSlider)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

return function(target: Instance)
    local ui = Nest {
        Parent = target,

        [Children] = {
            HorizontalSlider {
                Parent = target,
                Size = UDim2.fromOffset(200, 20)
            },

            ShorthandPadding { Padding = UDim.new(0, 64) }
        }
    }

    return function()
        ui:Destroy()
    end
end