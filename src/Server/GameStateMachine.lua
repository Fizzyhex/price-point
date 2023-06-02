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

function GameStateMachine:PickNextProduct()
    if self._currentProduct then
        local currentProducts = self._ProductFeedStateContainer:GetAll()

        if #currentProducts > 10 then
            table.remove(currentProducts, 1)
        end

        table.insert(currentProducts, 1, {
            id = self._currentProduct.Id or self._currentProduct.AssetId,
            type = if self._currentProduct.BundleType then Enum.AvatarItemType.Bundle else Enum.AvatarItemType.Asset
        })
        self._ProductFeedStateContainer:Patch(currentProducts)
    end

    local product = self:_GetRandomProduct()
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

function GameStateMachine:_GetRandomProduct()
    local categories = TableUtil.Keys(self._productPools)
    local randomCategory = categories[RANDOM:NextInteger(1, #categories)]
    local productData = self._productPools[randomCategory]:Pop()
    local infoType = if productData.itemType == "Bundle" then Enum.InfoType.Bundle else Enum.InfoType.Asset

    local ok, marketplaceInfo = pcall(function()
        return MarketplaceService:GetProductInfo(productData.id, infoType)
    end)

    if not ok then
        logger.warn(`Failed to fetch marketplace info for {productData.id}: {marketplaceInfo}`)
        task.wait(0.5)
        return self:_GetRandomProduct()
    end

    -- Use the cached price if it's not provided within the MarketplaceInfo (e.g for bundles) (why)
    marketplaceInfo.PriceInRobux = marketplaceInfo.PriceInRobux or productData.price
    return marketplaceInfo
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

function GameStateMachine.new(stateContainers, productPools)
    local self = setmetatable({}, GameStateMachine)
    self._roundStateContainer = stateContainers.roundStateContainer
    self._scoreStateContainer = stateContainers.scoreStateContainer
    self._guessStateContainer = stateContainers.guessStateContainer
    self._ProductFeedStateContainer = stateContainers.ProductFeedStateContainer
    self._productPools = productPools
    self._roundsRemaining = assert(gameRules:GetAttribute("rounds"), "'rounds' game rule is not set")
    self._guesses = {}
    return self
end

return GameStateMachine