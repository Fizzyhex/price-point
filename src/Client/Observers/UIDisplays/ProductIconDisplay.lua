local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local ProductImageCard = require(ReplicatedStorage.Client.UI.Components.ProductImageCard)
local StateContainers = require(ReplicatedStorage.Shared.StateContainers)
local roundStateContainer = StateContainers.roundStateContainer
local ImageScroller = require(ReplicatedStorage.Client.UI.Components.ImageScroller)

local ANCESTORS = { workspace }

local function ProductIconDisplay()
    return Observers.observeTag("ProductIconDisplay", function(parent: Instance)
        local isVisible = Value(false)
        local currentProductData = Value(nil)
        local currentProductImage = Computed(function()
            local data = currentProductData:get()
            return if data then data.image else ""
        end)

        local stopObservingRoundState = roundStateContainer:Observe(function(_, newState)
            isVisible:set(newState.phase ~= "Intermission" and newState.phase ~= "GameOver")
        end)

        local roundStateHook = roundStateContainer.FusionUtil.StateHook(roundStateContainer, currentProductData, "productData")
        local frame = New "CanvasGroup" {
            Name = "ProductIconDisplay",
            Parent = parent,
            Size = UDim2.fromScale(1, 1),

            GroupTransparency = Spring(Computed(function()
                return if isVisible:get() then 0.15 else 1
            end)),

            [Children] = {
                Background {
                    Archivable = false,

                    [Children] = {
                        ProductImageCard {
                            ZIndex = 2,
                            Size = UDim2.fromScale(1, 1),
                            Image = currentProductImage,
                            ImageTransparency = 0,
                            BackgroundTransparency = 0.3
                        },

                        ShorthandPadding { Padding = UDim.new(0, 6) }
                    }
                }
            }
        }

        return function()
            stopObservingRoundState()
            roundStateHook:Disconnect()
            frame:Destroy()
        end
    end, ANCESTORS)
end

return ProductIconDisplay