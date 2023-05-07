local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local Promise = require(ReplicatedStorage.Packages.Promise)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local PriceGuessing = require(ServerStorage.Server.GameStates.PriceGuessing)
local PriceReveal = require(ServerStorage.Server.GameStates.PriceReveal)

local MatchConfig = require(ServerStorage.Server.Types.MatchConfig)

local RANDOM = Random.new()
local DEFAULT_STATS = {
    score = 0
}

local logger = CreateLogger(script)

local function GenerateDefaultStats(players: {Player})
    local dict = {}

    for _, player in players do
        dict[player.UserId] = DEFAULT_STATS
    end

    return dict
end

-- Manages flow between different match states
local function MatchHandler(matchConfig: MatchConfig.MatchConfig)
    return Promise.new(function(resolve, reject)
        local replicatedRoundState = matchConfig.replicatedRoundState
        local scoreState = matchConfig.scoreState
        local productPools = matchConfig.productPools
        local rounds = matchConfig.rounds
        local replicationBin = matchConfig.replicationBin or Instance.new("Folder")

        local function FetchRandomProduct()
            local categories = TableUtil.Keys(productPools)
            local randomCategory = categories[RANDOM:NextInteger(1, #categories)]
            local productData = productPools[randomCategory]:Pop()
            local infoType = if productData.itemType == "Bundle" then Enum.InfoType.Bundle else Enum.InfoType.Asset

            local ok, marketplaceInfo = pcall(function()
                return MarketplaceService:GetProductInfo(productData.id, infoType)
            end)

            if not ok then
                logger.error(`Failed to fetch marketplace info for {productData.id}: {marketplaceInfo}`)
                task.wait(0.5)
                return FetchRandomProduct()
            end

            -- Use the cached price if it's not provided witin the MarketplaceInfo (e.g for bundles)
            marketplaceInfo.PriceInRobux = marketplaceInfo.PriceInRobux or productData.price

            return marketplaceInfo
        end

        scoreState:Clear()
        scoreState:Patch(GenerateDefaultStats(Players:GetPlayers()))

        for currentRound = 1, rounds do
            replicatedRoundState:Patch({roundNumber = currentRound})
            local productData = FetchRandomProduct()
            replicatedRoundState:Patch({roundNumber = currentRound})

            local _, priceGuessingResult = PriceGuessing(
                matchConfig,
                {productData = productData, replicationBin = replicationBin}
            )
            :catch(logger.warn)
            :await()

            task.wait(2)

            PriceReveal(
                matchConfig,
                priceGuessingResult
            )
            :catch(logger.warn)
            :await()
        end

        resolve()
    end)
end

return MatchHandler