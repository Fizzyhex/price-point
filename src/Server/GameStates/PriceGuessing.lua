local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local ServerItemProjector = require(ServerStorage.Server.Components.ServerItemProjector)
local MarketplacePreviewUtil = require(ServerStorage.Server.Util.MarketplacePreviewUtil)

local logger = CreateLogger(script)

local function AssetTypeIdToEnum(id)
    for _, enumItem: EnumItem in Enum.AssetType:GetEnumItems() do
        if enumItem.Value == id then
            return enumItem
        end
    end
end

local function PriceGuessing(system)
    return Promise.new(function(resolve)
        local replicatedRoundState = system:GetRoundStateContainer()
        local scoreState = system:GetScoreStateContainer()
        local guessTime = system:GetGuessTime()
        local productData = system:PickNextProduct()

        replicatedRoundState:Clear()
        scoreState:Clear()

        local id = productData.Id or productData.AssetId
        local assetType: EnumItem? = AssetTypeIdToEnum(productData.AssetTypeId)
        local assetTypeName = if assetType then assetType.Name else nil
        local price = productData.PriceInRobux or 0

        if productData.BundleType then
            assetTypeName = "Bundle"
        end

        local imageUri =
            if productData.BundleType then `rbxthumb://type=BundleThumbnail&id={id}&w=420&h=420`
            else `rbxthumb://type=Asset&id={id}&w=420&h=420`

        for _, component in ServerItemProjector:GetAll() do
            component:SetModel(nil)
        end

        replicatedRoundState:Patch({
            phase = "PriceGuessing",
            guessingEnabled = true,
            productData = {
                image = imageUri,
                name = productData.Name,
                type = assetTypeName
            },
        })

        local preview =
            if productData.BundleType
            then MarketplacePreviewUtil.GetHumanoidDescriptionFromBundleId(id)
            elseif productData.AssetId then MarketplacePreviewUtil.CreateAssetPreviewFromId(id)
            else nil

        local isHumanoidDescription = preview and preview:IsA("HumanoidDescription")

        if preview then
            for _, component in ServerItemProjector:GetAll() do
                if isHumanoidDescription then
                    component:SetModel(
                        MarketplacePreviewUtil.bundlePreviewCharacterPrefab:Clone(),
                        preview
                    )
                else
                    component:SetModel(preview:Clone())
                end
            end
        end

        system:ClearGuesses()
        system:OpenGuessing()
        task.wait(guessTime)
        system:CloseGuessing()
        replicatedRoundState:Patch({guessingEnabled = false})
        logger.print("Closed guessing")
        resolve(system:GetStateByName("PriceReveal"))
    end)
end

return PriceGuessing