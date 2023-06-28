local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")
local RunService = game:GetService("RunService")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value
local Children = Fusion.Children

local StateContainers = require(ReplicatedStorage.Shared.StateContainers)
local productFeedStateContainer = StateContainers.productFeedStateContainer
local AvatarItemFeed = require(ReplicatedStorage.Client.UI.Components.AvatarItemFeedOld)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)

local ANCESTORS = { workspace }
local TAG = "ProductFeedDisplayOld"
local LOCAL_PLAYER = Players.LocalPlayer
local USE_RED_HACK = true
local ADD_TEST_ITEMS = false -- RunService:IsStudio()
local MAX_PRODUCTS = 100

local function ProductFeedDisplay()
    local products = Value({})
    local avatarNetwork = Red.Client(NetworkNamespaces.AVATAR)

    productFeedStateContainer:Observe(function(_, newState)
        local currentProductData = products:get()
        local newProductData = {}

        for _, productData in newState do
            local isNew = true

            for _, product in currentProductData do
                if product.id == productData.id then
                    isNew = false
                    break
                end
            end

            if isNew then
                table.insert(newProductData, productData)
            end
        end

        if #newProductData > 0 then
            local data = TableUtil.Extend(currentProductData, newProductData)

            if MAX_PRODUCTS > 0 then
                while #data > MAX_PRODUCTS do
                    table.remove(data, 1)
                end
            end

            products:set(data)
        end
    end)

    local function EquipItem(itemId: number, assetType: string, successCallback: () -> ())
        print("Sent equip", itemId, assetType, successCallback)

        if USE_RED_HACK then
            local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildWhichIsA("Humanoid")
            avatarNetwork:Fire("Equip", itemId, assetType)
            local connectionBinAdd, connectionBinEmpty = Bin()
            local currentDescription = humanoid:GetAppliedDescription()

            local function PromptSave(humanoidDescription: HumanoidDescription)
                print("Prompt to save avi")
                connectionBinEmpty()

                if not humanoidDescription then
                    return
                end

                AvatarEditorService:PromptSaveAvatar(humanoidDescription, humanoid.RigType)
            end

            if currentDescription then
                connectionBinAdd(currentDescription.Changed:Connect(function(change)
                    if change == "Parent" then
                        return
                    end

                    PromptSave()
                end))
            end

            -- For some ungodly reason, Roblox will likely destroy the current HumanoidDescription and replace
            -- it with a new one when we re-apply the description.
            humanoid.ChildAdded:Connect(function(child: Instance)
                if child:IsA("HumanoidDescription") then
                    PromptSave(child)
                end
            end)

            task.delay(8, connectionBinEmpty)
        else
            avatarNetwork:Call("Equip", itemId, assetType):Then(function(ok: boolean)
                if ok then
                    local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildWhichIsA("Humanoid")
                    local description = humanoid and humanoid:GetAppliedDescription()
                    AvatarEditorService:PromptSaveAvatar(description, humanoid.RigType)

                    if successCallback then
                        successCallback()
                    end
                else
                    warn("Server failed to equip item")
                end
            end)
        end
    end

    local function UnequipItem(itemId: number, assetType: string, successCallback)
        avatarNetwork:Call("Unequip", itemId, assetType):Then(function(ok: boolean)
            if ok then
                local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildWhichIsA("Humanoid")
                local description = humanoid and humanoid:GetAppliedDescription()
                AvatarEditorService:PromptSaveAvatar(description, humanoid.RigType)

                if successCallback then
                    successCallback()
                end
            else
                warn("Server failed to equip item")
            end
        end)
    end

    if ADD_TEST_ITEMS then
        productFeedStateContainer:Patch({
            [1] = {id = 9490601996, type = Enum.AvatarItemType.Asset},
            [2] = {id = 496, type = Enum.AvatarItemType.Bundle}
        })
    end

    Observers.observeTag(TAG, function(target: Instance)
        local ui = Nest {
            Parent = target,

            [Children] = {
                AvatarItemFeed {
                    Products = products,
                    EquipCallback = EquipItem,
                    UnequipCallback = UnequipItem
                },
            }
        }

        return function()
            -- omg it's just like horacekat
            ui:Destroy()
        end
    end, ANCESTORS)
end

return ProductFeedDisplay