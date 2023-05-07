local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BasicStateContainer = require(ReplicatedStorage.Shared.BasicStateContainer)
local StateReplicator = require(ServerStorage.Server.StateReplicator)
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
local DEFAULT_STATS = {
    score = 0
}

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

local function GenerateDefaultStats(players: {Player})
    local dict = {}

    for _, player in players do
        dict[player.UserId] = DEFAULT_STATS
    end

    return dict
end

local GameStateMachine = {}
GameStateMachine.__index = GameStateMachine

function GameStateMachine:GetGuessTime()
    return 10
end

function GameStateMachine:GetRounds()
    return 5
end

function GameStateMachine:GetIntermissionLength()
    return 3
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

function GameStateMachine:OpenGuessing()
    self._stopCollectingGuesses = PlayerGuessRecorder()
end

function GameStateMachine:CloseGuessing()
    if self._stopCollectingGuesses then
        self._guesses = self._stopCollectingGuesses()
    end
end

function GameStateMachine:ClearGuesses()
    table.clear(self._guesses)
end

function GameStateMachine:GetGuesses()
    return self._guesses
end

function GameStateMachine:PickNextProduct()
    local product = self:_GetRandomProduct()
    self._currentProduct = product
    return product
end

function GameStateMachine:GetRoundsRemaining()
    return self._roundsRemaining
end

function GameStateMachine:DecreaseRoundsRemaining()
    self._roundsRemaining -= 1
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
        logger.error(`Failed to fetch marketplace info for {productData.id}: {marketplaceInfo}`)
        task.wait(0.5)
        return self:_GetRandomProduct(self._productPools)
    end

    -- Use the cached price if it's not provided witin the MarketplaceInfo (e.g for bundles)
    marketplaceInfo.PriceInRobux = marketplaceInfo.PriceInRobux or productData.price

    return marketplaceInfo
end

function GameStateMachine:Start(endCallback)
    local isRunning = true
    self._scoreStateContainer:Patch(CreateInitialScoreboard(Players:GetPlayers()))

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

function GameStateMachine.new(roundStateContainer, scoreStateContainer, productPools)
    local self = setmetatable({}, GameStateMachine)
    self._roundStateContainer = roundStateContainer
    self._scoreStateContainer = scoreStateContainer
    self._productPools = productPools
    self._roundsRemaining = assert(gameRules:GetAttribute("rounds"), "'rounds' game rule is not set")
    self._guesses = {}
    return self
end

return GameStateMachine