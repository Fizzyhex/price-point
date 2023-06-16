local MarketplaceService = game:GetService("MarketplaceService")
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
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local Children = Fusion.Children
local ForPairs = Fusion.ForPairs
local ForValues = Fusion.ForValues
local Value = Fusion.Value
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup
local New = Fusion.New
local Computed = Fusion.Computed

local SUPPORTED_ITEM_TYPES = {
    Enum.AvatarItemType.Asset,
    Enum.AvatarItemType.Bundle
}

local function ProductTypeFilter(products, supportedType: Enum.AvatarItemType)
    return ForValues(products, function(product)
        local avatarItemType = product.type

        if supportedType == avatarItemType then
            return product
        else
            return nil
        end

    end, Fusion.doNothing)
end

local function ProductDetailsCache(products, avatarItemType: Enum.AvatarItemType)
    local cache = Value({})

    local function IsInCache(product)
        for _, item in cache:get() do
            if tostring(item.id) == tostring(product.id) then
                return true
            end
        end

        return false
    end

    local function PruneCache()
        local currentProducts = products:get()
        local newCache = cache:get()

        for index, itemDetails in cache:get() do
            local isRedundant = true

            for _, product in currentProducts do
                if tostring(product.Id) == tostring(itemDetails.Id) then
                    isRedundant = false
                    break
                end
            end

            if isRedundant then
                table.remove(newCache, index)
            end
        end

        cache:set(newCache)
    end

    local function UpdateCache()
        local payload = {}

        for _, product in Unwrap(products) do
            if not IsInCache(product) then
                table.insert(payload, product.id)
            end
        end

        if #payload == 0 then
            return
        end

        local itemDetailsBatch = AvatarEditorService:GetBatchItemDetails(payload, avatarItemType)

        for index, itemDetails in itemDetailsBatch do
            itemDetails.InjectedType = avatarItemType
            itemDetails.Id = itemDetails.Id or payload[index]
        end

        PruneCache()
        cache:set(TableUtil.Extend(cache:get(), itemDetailsBatch))
    end

    task.spawn(UpdateCache)
    local DestroyObserver = Observer(products):onChange(UpdateCache)
    return cache, DestroyObserver
end

local function AvatarItemFeed(props)
    local products = props.Products
    local equipCallback = props.EquipCallback
    local unequipCallback = props.UnequipCallback
    local itemDetailsDict = {}
    local cleanupFns = {}

    for _, itemType in SUPPORTED_ITEM_TYPES do
        local productsOfItemType = ProductTypeFilter(products, itemType)
        local itemDetails, CleanupCache = ProductDetailsCache(productsOfItemType, itemType)
        itemDetailsDict[itemType] = itemDetails
        table.insert(cleanupFns, CleanupCache)
    end

    return Background {
        Name = "AvatarItemFeedDisplay",
        Size = props.Size,
        Position = props.Position,
        AnchorPoint = props.AnchorPoint,
        Parent = props.Parent,
        BackgroundColor3 = Color3.new(1, 1, 1),

        [Cleanup] = cleanupFns,
        [Children] = {
            -- Header {
            --     Text = "Product Feed",
            --     Size = UDim2.new(1, 0, 0, 50)
            -- },

            New "UIGradient" {
                Color = Computed(function()
                    local accentColor = ThemeProvider:GetColor("accent"):get()
                    local backgroundColor = ThemeProvider:GetColor("background"):get()
                    return ColorSequence.new(backgroundColor, accentColor:Lerp(backgroundColor, 0.8))
                end),
                Rotation = 90
            },

            ScrollFrame {
                Size = UDim2.new(1, 0, 1, -112),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                CanvasSize = UDim2.fromScale(0, 0),

                [Children] = {
                    ForPairs(products, function(index, product)
                        local detailsCache = itemDetailsDict[product.type]
                        local id = product.id
                        local itemDetails

                        if not detailsCache then
                            return index, nil
                        end

                        for _, data in detailsCache:get() do
                            if data.Id == id then
                                itemDetails = data
                                break
                            end
                        end

                        if not itemDetails then
                            return index, nil
                        end

                        return index, AvatarItemCard {
                            LayoutOrder = -index,
                            Id = itemDetails.Id,
                            AvatarItemType = itemDetails.InjectedType,
                            ItemDetails = itemDetails,
                            Size = UDim2.new(1, 0, 0, 100),
                            BackgroundTransparency = 0.5,
                            EquipCallback = equipCallback,
                            UnequipCallback = unequipCallback
                        }
                    end, Fusion.cleanup),

                    VerticalListLayout { Padding = UDim.new(0, 12) },
                    ShorthandPadding { Padding = UDim.new(0, 12) }
                }
            },

            Nest {
                [Children] = {
                    Label {
                        Text = "♥ i get a 40% commission on any items bought through the game.",
                        TextWrapped = true,
                        Position = UDim2.fromScale(0.5, 1),
                        AnchorPoint = Vector2.new(0.5, 1),
                        Size = UDim2.new(1, 0, 0, 0)
                    },

                    ShorthandPadding { Padding = UDim.new(0, 12) },
                }
            },
        }
    }
end

return AvatarItemFeed