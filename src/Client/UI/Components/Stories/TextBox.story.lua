local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local TextBox = require(ReplicatedStorage.Client.UI.Components.TextBox)

local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local TextFilters = require(ReplicatedStorage.Client.UI.Util.TextFilters)

return function(target: Instance)
    local story = Nest {
        Parent = target,

        [Children] = {
            VerticalListLayout { Padding = UDim.new(0, 16) },
            ShorthandPadding { Padding = UDim.new(0, 8) },

            TextBox {
                Parent = target,
                PlaceholderText = "Enter text here"
            },

            TextBox {
                Parent = target,
                PlaceholderText = "Enter whole number here (16)",
                TextFilters = {
                    TextFilters.WholeNumber(),
                    TextFilters.MaxLength(16)
                }
            }
        }
    }

    return function()
        story:Destroy()
    end
end