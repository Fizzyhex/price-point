local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)

local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local ScrollFrame = require(ReplicatedStorage.Client.UI.Components.ScrollFrame)
local AvatarItemCard = require(ReplicatedStorage.Client.UI.Components.AvatarItemCard)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local Children = Fusion.Children
local ForPairs = Fusion.ForPairs
local Value = Fusion.Value
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup
local Computed = Fusion.Computed

local function ProductFeed(props)
    local products = props.Products
    local avatarItemArray = Value({})
    local itemDetailsValue = Computed(function()
        local data = {}

        ForPairs(avatarItemArray:get(), function(avatarItemType, itemDetailsArray)
            data = TableUtil.Extend(data, itemDetailsArray)
            return avatarItemType, itemDetailsArray
        end)

        return data
    end)

    local function UpdateItemData()
        local newState = table.clone(avatarItemArray:get())
        local toFetch: {[Enum.AvatarItemType]: {number}} = {}

        for _, product in products:get() do
            if not newState[product.type] then
                newState[product.type] = {}
            end

            if not newState[product.type][product.id] then
                toFetch[product.type] = toFetch[product.type] or {}
                table.insert(toFetch[product.type], product.id)
            end
        end

        for avatarItemType, itemIds in toFetch do
            if #itemIds == 1 then
                local id = itemIds[1]
                local itemDetails = AvatarEditorService:GetItemDetails(id, avatarItemType)
                itemDetails.InjectedType = avatarItemType
                newState[avatarItemType][id] = itemDetails
            elseif #itemIds > 1 then
                local itemDetailsArray = AvatarEditorService:GetBatchItemDetails(itemIds, avatarItemType)

                for _, itemDetails in itemDetailsArray do
                    itemDetails.InjectedType = avatarItemType
                    newState[avatarItemType][itemDetails.Id] = itemDetails
                end
            end
        end

        avatarItemArray:set(newState)
    end

    task.spawn(UpdateItemData)

    return Background {
        Name = "ProductFeedDisplay",
        Size = props.Size,
        Position = props.Position,
        AnchorPoint = props.AnchorPoint,
        Parent = props.Parent,

        [Cleanup] = { Observer(products):onChange(UpdateItemData) },

        [Children] = {
            Header {
                Text = "Product Feed",
                Size = UDim2.new(1, 0, 0, 50)
            },

            ScrollFrame {
                Size = UDim2.new(1, 0, 1, -112),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.fromScale(0, 0),

                [Children] = {
                    ForPairs(itemDetailsValue, function(index, itemDetails: table)
                        return index, AvatarItemCard {
                            LayoutOrder = -index,
                            Id = itemDetails.Id,
                            AvatarItemType = itemDetails.InjectedType,
                            ItemDetails = itemDetails,
                            Size = UDim2.new(1, 0, 0, 100)
                        }
                    end, Fusion.cleanup),

                    VerticalListLayout { Padding = UDim.new(0, 12) },
                    ShorthandPadding { Padding = UDim.new(0, 12) }
                }
            },

            Nest {
                Size = UDim2.fromScale(1, 0),

                [Children] = {
                    Label {
                        Text = "note that i get a 40% commission for items you buy through the game. thanks!",
                        TextWrapped = true,
                        Position = UDim2.fromScale(0.5, 0),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Size = UDim2.new(1, 0, 0, 50)
                    },

                    ShorthandPadding { Padding = UDim.new(0, 12) },
                }
            },

            VerticalListLayout { HorizontalAlignment = Enum.HorizontalAlignment.Center }
        }
    }
end

return ProductFeed