local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BasicStateContainer = require(ReplicatedStorage.Shared.BasicStateContainer)
local MatchHandler = require(ServerStorage.Server.MatchHandler)
local AvatarShopData = require(ServerStorage.Server.AvatarShopData)
local RandomPool = require(ReplicatedStorage.Shared.RandomPool)
local StateReplicator = require(ServerStorage.Server.StateReplicator)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local MatchConfig = require(ServerStorage.Server.Types.MatchConfig)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local GetReplicationBin = require(ReplicatedStorage.Shared.GetReplicationBin)
local GameStateMachine = require(ServerStorage.Server.GameStateMachine)

local logger = CreateLogger(script)

local function MakeProductPools()
    local productPools = {}

    for category, productIds in AvatarShopData do
        productPools[category] = RandomPool.new(productIds)
    end

    return productPools
end

local GameManager = {}

function GameManager:OnStart()
    logger.print("Starting game state machine...")
    local productPools = MakeProductPools()

    local roundStateContainer = BasicStateContainer.new()
    StateReplicator(NetworkNamespaces.ROUND_STATE_CONTAINER, roundStateContainer)
    local scoreStateContainer = BasicStateContainer.new()
    StateReplicator(NetworkNamespaces.SCORE_STATE_CONTAINER, scoreStateContainer)
    productPools = MakeProductPools()

    local function RunGame()
        logger.print("Running game")
        return GameStateMachine.new(
            roundStateContainer,
            scoreStateContainer,
            productPools
        ):Start(function()
            logger.print("Starting a new game")
            task.spawn(RunGame)
        end)
    end

    RunGame()
end

return GameManager