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
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)

local ANCESTORS = { workspace }

local function ItemTitleDisplay()
    return Observers.observeTag("ItemTitleDisplay", function(parent: Instance)
        local currentProductData = Value(nil)
        local winnerName = Value(nil)

        local currentProductName = Computed(function()
            local data = currentProductData:get()
            return if data then data.name else nil
        end)

        local currentProductType = Computed(function()
            local data = currentProductData:get()
            return if data then data.type else nil
        end)

        local roundStateHook = RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, currentProductData, "productData")
        local winnerNameStateHook = RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, winnerName, "winnerName")

        local frame = Background {
            Parent = parent,

            [Children] = {
                Header {
                    Size = UDim2.fromScale(1, 0.6),

                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextScaled = true,

                    AutomaticSize = Enum.AutomaticSize.None,

                    Text = Computed(function()
                        if winnerName:get() then
                            return `{winnerName:get()} won the game!`
                        end

                        return currentProductName:get() or ""
                    end)
                },

                Header {
                    Position = UDim2.fromScale(0, 1),
                    AnchorPoint = Vector2.new(0, 1),
                    Size = UDim2.fromScale(1, 0.4),

                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextScaled = true,

                    AutomaticSize = Enum.AutomaticSize.None,

                    Text = Computed(function()
                        if winnerName:get() then
                            return "Congratulations!"
                        end

                        local genre = currentProductType:get() or ""
                        return `Type: {genre}`
                    end)
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

return ItemTitleDisplay