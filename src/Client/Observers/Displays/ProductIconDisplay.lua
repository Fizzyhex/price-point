local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed

local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local ProductImageCard = require(ReplicatedStorage.Client.UI.Components.ProductImageCard)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)

local ANCESTORS = { workspace }

local function ProductIconDisplay()
    return Observers.observeTag("ProductIconDisplay", function(parent: Instance)
        local currentProductData = Value(nil)
        local currentProductImage = Computed(function()
            local data = currentProductData:get()
            return if data then data.image else ""
        end)

        local roundStateHook = RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, currentProductData, "productData")
        local frame = Background {
            Parent = parent,
            Archivable = false,

            [Children] = {
                ProductImageCard {
                    Size = UDim2.fromScale(1, 1),
                    Image = currentProductImage,
                    ImageTransparency = 0.5,
                    BackgroundTransparency = 0.3
                },
                ShorthandPadding { Padding = UDim.new(0, 12) }
            }
        }

        return function()
            roundStateHook:Disconnect()
            frame:Destroy()
        end
    end, ANCESTORS)
end

return ProductIconDisplay