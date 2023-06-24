local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local MarketplacePreviewUtil = require(ServerStorage.Server.Util.MarketplacePreviewUtil)
local ItemModelChannel = require(ServerStorage.Server.EventChannels.ItemModelChannel)
local ServerGameStateChannel = require(ServerStorage.Server.EventChannels.ServerGameStateChannel)

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
        local roundStateContainer = system:GetRoundStateContainer()
        local guessTime = system:GetGuessingTime()
        local productData = system:PickNextProduct()
        local id = productData.Id or productData.AssetId
        local assetType: EnumItem? = AssetTypeIdToEnum(productData.AssetTypeId)
        local assetTypeName = if assetType then assetType.Name else nil
        local receivedGuesses = 0
        local isResolved = false
        local timerThread

        ServerGameStateChannel.RaiseNewRound()

        if productData.BundleType then
            assetTypeName = "Bundle"
        end

        local imageUri =
            if productData.BundleType then `rbxthumb://type=BundleThumbnail&id={id}&w=420&h=420`
            else `rbxthumb://type=Asset&id={id}&w=420&h=420`
        ItemModelChannel.RaiseItemChanged(nil)

        local productDataPayload = {
            image = imageUri,
            name = productData.Name,
            type = assetTypeName,
        }

        if productData.Created then
            productDataPayload.year = tonumber(string.match(productData.Created, "%d+"))
        end

        roundStateContainer:Patch({
            phase = "PriceGuessing",
            guessingEnabled = true,
            roundTimer = workspace:GetServerTimeNow(),
            roundDuration = guessTime,
            productData = productDataPayload
        })

        logger.print("Players are guessing product:", productData)

        task.spawn(function()
            local preview =
                if productData.BundleType
                then MarketplacePreviewUtil.CreateBundlePreviewFromId(id)
                elseif productData.AssetId then MarketplacePreviewUtil.CreateAssetPreviewFromId(id)
                else nil

            if preview then
                ItemModelChannel.RaiseItemChanged(preview, assetType)
            end
        end)

        local function Advance()
            if isResolved then
                return
            end

            isResolved = true
            system:CloseGuessing()
            roundStateContainer:Patch({guessingEnabled = false})
            logger.print("Closed guessing")
            resolve(system:GetStateByName("PriceReveal"))
        end

        local function OnGuess(player: Player, guess)
            receivedGuesses += 1

            if receivedGuesses >= #system:GetActivePlayers() then
                if timerThread then
                    task.cancel(timerThread)
                    timerThread = nil
                end

                Advance()
            end
        end

        system:ClearGuesses()
        system:OpenGuessing(OnGuess)
        timerThread = task.delay(guessTime, Advance)
    end)
end

return PriceGuessing