local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local RunService = game:GetService("RunService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local StateContainers = require(ReplicatedStorage.Shared.StateContainers)
local productFeedStateContainer = StateContainers.productFeedStateContainer

local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local AvatarItemCard = require(ReplicatedStorage.Client.UI.Components.AvatarItemCard)
local ScrollFrame = require(ReplicatedStorage.Client.UI.Components.ScrollFrame)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local Value = Fusion.Value
local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs

local LOCAL_PLAYER = Players.LocalPlayer
local ENABLE_STUDIO_TEST_ITEMS = false

local logger = CreateLogger(script)

local function ProductFeedDisplay()
    local history = Value({})
    local avatarNetwork = Red.Client(NetworkNamespaces.AVATAR)

    local function GetInfo(id, type)
        local value = Value({})

        task.spawn(function()
            value:set(AvatarEditorService:GetItemDetails(id, type))
        end)

        return value
    end

    MarketplaceService.PromptBundlePurchaseFinished:Connect(function(purchaser, bundleId, wasPurchased)
        if not wasPurchased then
            return
        end

        for _, value in history:get() do
            if tostring(value.id) == tostring(bundleId) and value.type == Enum.AvatarItemType.Bundle then
                local newInfo = value.info:get()
                newInfo.Owned = true
                value.info:set(newInfo)
            end
        end
    end)

    MarketplaceService.PromptPurchaseFinished:Connect(function(purchaser, assetId, wasPurchased)
        if not wasPurchased then
            return
        end

        for _, value in history:get() do
            if tostring(value.id) == tostring(assetId) and value.type == Enum.AvatarItemType.Asset then
                local newInfo = value.info:get()
                newInfo.Owned = true
                value.info:set(newInfo)
            end
        end
    end)

    productFeedStateContainer:Observe(function(_, newState)
        local newHistory = {}

        for _, data in newState do
            local isInHistory = false

            for _, queued in history:get() do
                if queued.id == data.id and queued.type == data.type then
                    isInHistory = true
                    break
                end
            end

            if isInHistory then
                continue
            end

            table.insert(newHistory, {
                id = data.id,
                type = data.type,
                lastClick = Value(),
                isEquipped = Value(false),
                info = GetInfo(data.id, data.type)
            })
        end

        history:set(TableUtil.Extend(history:get(), newHistory))
    end)

    if ENABLE_STUDIO_TEST_ITEMS and RunService:IsStudio() then
        productFeedStateContainer:Patch({
            {id = 9490601996, type = Enum.AvatarItemType.Asset},
            {id = 496, type = Enum.AvatarItemType.Bundle},
            {id = 161, type = Enum.AvatarItemType.Bundle}
        })
    end

    local function AvatarUpdateCallback(worked: boolean)
        if not worked then
            logger.warn(`Failed to equip avatar item: server returned {worked}`)
            return
        end

        local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildWhichIsA("Humanoid")
        local description = humanoid and humanoid:GetAppliedDescription()
        AvatarEditorService:PromptSaveAvatar(description, humanoid.RigType)
    end

    Observers.observeTag("ProductFeedDisplay", function(parent: Instance)
        local ui = Background {
            Name = "ProductFeedDisplay",
            Parent = parent,

            [Children] = {
                Nest {
                    Name = "PaddedContent",
                    ZIndex = 2,

                    [Children] = {
                        Header {
                            Name = "EmptyLabel",
                            Size = UDim2.fromScale(1, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            TextWrapped = true,
                            Text = "Empty... but any new marketplace items will appear here after their prices are guessed!",
                            ZIndex = 2,
                            Visible = Computed(function()
                                return #history:get() == 0
                            end)
                        },

                        ShorthandPadding { Padding = UDim.new(0, 8) }
                    }
                },

                ScrollFrame {
                    Size = UDim2.fromScale(1, 1),
                    CanvasSize = UDim2.fromScale(1, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,

                    [Children] = {
                        ForPairs(history, function(index, data)
                            local info = data.info
                            local isEquipped = data.isEquipped
                            local lastClick = data.lastClick
                            local action = Computed(function()
                                if info:get().Owned then
                                    if info:get().BundleType then
                                        return "wear"
                                    else
                                        return if isEquipped:get() then "unequip" else "equip"
                                    end
                                elseif info:get().IsPurchasable == false then
                                    return "off-sale"
                                else
                                    return "purchase"
                                end
                            end)

                            return index, AvatarItemCard {
                                LayoutOrder = -index,
                                Size = UDim2.fromScale(1, 0),

                                Name = Computed(function()
                                    return info:get().Name or "???"
                                end),

                                Price = Computed(function()
                                    local lowestPrice = info:get().LowestPrice
                                    local price = info:get().Price or 0
                                    return if lowestPrice ~= nil and lowestPrice > 0 then lowestPrice else price
                                end),

                                Image = Computed(function()
                                    if data.type == Enum.AvatarItemType.Bundle then
                                        return `rbxthumb://type=BundleThumbnail&id={data.id}&w=150&h=150`
                                    else
                                        return `rbxthumb://type=Asset&id={data.id}&w=150&h=150`
                                    end
                                end),

                                OnActionClicked = function()
                                    if lastClick:get() and tick() - lastClick:get() < 0.3 then
                                        return false
                                    end

                                    lastClick:set(tick())

                                    if action:get() == "purchase" then
                                        if data.type == Enum.AvatarItemType.Bundle then
                                            MarketplaceService:PromptBundlePurchase(LOCAL_PLAYER, data.id)
                                        else
                                            MarketplaceService:PromptPurchase(LOCAL_PLAYER, data.id)
                                        end
                                    elseif action:get() == "equip" or action:get() == "wear" then
                                        avatarNetwork
                                        :Call("Equip", data.id, info:get().AssetType, info:get().BundleType)
                                        :Then(function(worked)
                                            if worked then
                                                isEquipped:set(true)
                                            end

                                            AvatarUpdateCallback(worked)
                                        end)
                                    elseif action:get() == "unequip" then
                                        avatarNetwork
                                        :Call("Unequip", data.id, info:get().AssetType, info:get().BundleType)
                                        :Then(function(worked)
                                            if worked then
                                                isEquipped:set(false)
                                            end

                                            AvatarUpdateCallback(worked)
                                        end)
                                    end
                                end,

                                Action = action
                            }
                        end, Fusion.cleanup),
                        ShorthandPadding { Padding = UDim.new(0, 8) },
                        VerticalListLayout { Padding = UDim.new(0, 8) },
                    }
                },
            }
        }

        return function()
            ui:Destroy()
        end
    end, { workspace })
end

return ProductFeedDisplay