local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local PlayerGuessRecorder = require(ServerStorage.Server.PlayerGuessRecorder)

local GameStates = require(ServerStorage.Server.GameStates)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Red = require(ReplicatedStorage.Packages.Red)
local StateContainers = require(ReplicatedStorage.Shared.StateContainers)

local gameRules = ReplicatedStorage.Assets.Configuration.GameRules
local logger = CreateLogger(script)
local scoreboardNetwork = Red.Server(NetworkNamespaces.SCOREBOARD)

local RANDOM = Random.new()

local function CreateInitialScoreboard(players: {Player})
    local scores = {}

    for _, player in players do
        scores[player.UserId] = 0
    end

    return scores
end

local function GetValueKey(dict: table, term: string)
    for key, value in dict do
        if value == term then
            return key
        end
    end

    return nil
end

local GameStateMachine = {}
GameStateMachine.__index = GameStateMachine

function GameStateMachine:GetGuessingTime()
    return gameRules:GetAttribute("guessingTime")
end

function GameStateMachine:GetRounds()
    return gameRules:GetAttribute("rounds")
end

function GameStateMachine:GetIntermissionTime()
    return gameRules:GetAttribute("intermissionTime")
end

function GameStateMachine:GetConclusionTime()
    return gameRules:GetAttribute("conclusionTime")
end

function GameStateMachine:GetRoundStateContainer()
    return self._roundStateContainer
end

function GameStateMachine:GetScoreStateContainer()
    return self._scoreStateContainer
end

function GameStateMachine:GetCurrentProduct()
    return self._currentProduct
end

function GameStateMachine:ResortScoreboards()
    scoreboardNetwork:FireAll("Resort")
end

function GameStateMachine:GetStateByName(name: string)
    return assert(GameStates[name], `State "{name} was not found within the GameState dictionary"`)
end

function GameStateMachine:OpenGuessing(callback)
    if self._stopCollectingGuesses then
        return
    end

    self._stopCollectingGuesses = PlayerGuessRecorder(function(player, guess)
        self._guessStateContainer:Patch({[player.UserId] = true})

        if callback then
            callback(player, guess)
        end
    end)
end

function GameStateMachine:RevealGuesses()
    self._guessStateContainer:Patch(self:GetGuesses())
end

function GameStateMachine:CloseGuessing()
    if self._stopCollectingGuesses then
        self._guesses = self._stopCollectingGuesses()
        self._stopCollectingGuesses = nil
    end
end

function GameStateMachine:ClearGuesses()
    self._guessStateContainer:Clear()
    table.clear(self._guesses)
end

function GameStateMachine:GetGuesses()
    return self._guesses
end

function GameStateMachine:SetModeName(mode)
    self._matchStateContainer:Patch({
        mode = if mode then mode else self._matchStateContainer.NONE
    })
end

function GameStateMachine:PickNextProduct()
    if self._currentProduct then
        local currentProductFeed = self._productFeedStateContainer:GetAll()

        if #currentProductFeed > 10 then
            table.remove(currentProductFeed, 1)
        end

        table.insert(currentProductFeed, 1, {
            id = self._currentProduct.Id or self._currentProduct.AssetId,
            type = if self._currentProduct.BundleType then Enum.AvatarItemType.Bundle else Enum.AvatarItemType.Asset
        })
        self._productFeedStateContainer:Patch(currentProductFeed)
    end

    local product = self:_GetRandomProduct(self:GetMatchCategories())
    self._currentProduct = product

    return product
end

function GameStateMachine:GetRoundsRemaining()
    return self._roundsRemaining
end

function GameStateMachine:DecreaseRoundsRemaining()
    self._roundsRemaining -= 1
    self._roundStateContainer:Patch({
        roundsRemaining = self._roundsRemaining
    })
end

function GameStateMachine:GetActivePlayers()
    return Players:GetPlayers()
end

function GameStateMachine:_GetRandomProduct(categories: table?)
    if not categories then
        categories = TableUtil.Keys(self._productPools)
    end

    local randomCategory = categories[RANDOM:NextInteger(1, #categories)]
    local productData = self._productPools[randomCategory]:Pop()
    local infoType = if productData.itemType == "Bundle" then Enum.InfoType.Bundle else Enum.InfoType.Asset

    local ok, marketplaceInfo = pcall(function()
        return MarketplaceService:GetProductInfo(productData.id, infoType)
    end)

    if not ok then
        logger.warn(`Failed to fetch marketplace info for {productData.id}: {marketplaceInfo}, trying again shortly`)
        task.wait(0.5)
        return self:_GetRandomProduct(categories)
    end

    -- Use the cached price if it's not provided within the MarketplaceInfo (e.g for bundles) (why)
    marketplaceInfo.PriceInRobux = marketplaceInfo.PriceInRobux or productData.price
    return marketplaceInfo
end

function GameStateMachine:PickMatchCategories()
    local categories = TableUtil.Sample(TableUtil.Keys(self._productPools), 2)
    self._matchCategories = categories
    logger.print("Picked categories:", categories)
    return table.clone(categories)
end

function GameStateMachine:GetMatchCategories()
    return self._matchCategories
end

function GameStateMachine:Start(endCallback)
    local isRunning = true
    self._scoreStateContainer:Patch(CreateInitialScoreboard(self:GetActivePlayers()))

    task.spawn(function()
        local currentState = GameStates.Intermission

        while isRunning do
            logger.print(`Transitioning to "{GetValueKey(GameStates, currentState) or `unknown state`}" state`)
            local ok, newState = currentState(self):catch(logger.warn):await()

            if newState == false then
                isRunning = false
                endCallback()
                self:Destroy()
                return
            end

            currentState = assert(newState, `Expected a new state, got {newState}`)

            if not ok then
                -- Prevent crashes caused by unyielding errors
                task.wait(0.5)
            end
        end
    end)

    return function()
        isRunning = false
    end
end

function GameStateMachine:SetItemDisplay(value: Instance | nil)
    self._itemDisplaySetter.Value = value
end

function GameStateMachine:ClearMatchStateContainer()
    self._matchStateContainer:Clear()
end

function GameStateMachine:Destroy()
    self._itemDisplaySetter:Destroy()
end

function GameStateMachine.new(productPools)
    local self = setmetatable({}, GameStateMachine)
    self._roundStateContainer = StateContainers.roundStateContainer
    self._scoreStateContainer = StateContainers.scoreStateContainer
    self._guessStateContainer = StateContainers.guessStateContainer
    self._productFeedStateContainer = StateContainers.productFeedStateContainer
    self._matchStateContainer = StateContainers.matchStateContainer
    self._productPools = productPools
    self._roundsRemaining = assert(gameRules:GetAttribute("rounds"), "'rounds' game rule is not set")
    self._guesses = {}

    local itemDisplaySetter = Instance.new("ObjectValue")
    itemDisplaySetter.Name = "ItemDisplaySetter"
    CollectionService:AddTag(itemDisplaySetter, "ItemDisplaySetter")
    itemDisplaySetter.Parent = workspace
    self._itemDisplaySetter = itemDisplaySetter

    return self
end

return GameStateMachine