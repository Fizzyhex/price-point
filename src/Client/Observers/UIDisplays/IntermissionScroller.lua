local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Observers = require(ReplicatedStorage.Packages.Observers)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)
local ImageScroller = require(ReplicatedStorage.Client.UI.Components.ImageScroller)
local New = Fusion.New
local Value = Fusion.Value
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Children = Fusion.Children

local ANCESTORS = { workspace }

local function IntermissionScroller()
    Observers.observeTag("IntermissionScroller", function(parent: Instance)
        local isVisible = Value(false)
        local stopObservingRoundState = RoundStateContainer:Observe(function(_, newState)
            isVisible:set(newState.phase == "Intermission")
        end)

        local ui = New "CanvasGroup" {
            Name = "IntermissionScroller",
            Parent = parent,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),

            GroupTransparency = Spring(Computed(function()
                return if isVisible:get() then 0.5 else 1
            end)),

            [Children] = {
                ImageScroller {
                    Name = "Checkers",
                    TileSize = UDim2.fromOffset(100, 100),
                    Velocity = Vector2.new(10, 10),
                    Size = UDim2.fromScale(2, 2),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    ZIndex = 2,
                    Image = "rbxassetid://13675238365"
                },

                ImageScroller {
                    Name = "QuestionMarks",
                    TileSize = UDim2.fromOffset(100, 100),
                    Velocity = Vector2.new(12, 12),
                    Size = UDim2.fromScale(2, 2),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Image = "rbxassetid://13675238492"
                }
            }
        }

        return function()
            stopObservingRoundState()
            ui:Destroy()
        end
    end, ANCESTORS)
end

return IntermissionScroller