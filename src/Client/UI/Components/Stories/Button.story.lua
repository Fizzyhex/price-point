local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local Value = Fusion.Value

local Button = require(ReplicatedStorage.Client.UI.Components.Button)
local PrimaryButton = require(ReplicatedStorage.Client.UI.Components.PrimaryButton)

local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local TextFilters = require(ReplicatedStorage.Client.UI.Util.TextFilters)

return function(target: Instance)
    local isHeld = Value(false)

    local story = Nest {
        Parent = target,

        [Children] = {
            VerticalListLayout { Padding = UDim.new(0, 16) },
            ShorthandPadding { Padding = UDim.new(0, 8) },

            Button {
                Text = "Button 1"
            },

            Button {
                Text = "Click to print!",
                OnClick = function()
                    print("Hi!")
                end
            },

            Button {
                Text = "Multi-line\nButton"
            },

            PrimaryButton {
                Text = "Primary Button"
            },

            PrimaryButton {
                Text = "Toggle Button",
                IsHeld = isHeld,

                OnClick = function()
                    isHeld:set(not isHeld:get())
                end
            },
        }
    }

    return function()
        story:Destroy()
    end
end