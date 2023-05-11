local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BasicStateContainer = require(ReplicatedStorage.Shared.BasicStateContainer)
local AvatarShopData = require(ServerStorage.Server.AvatarShopData)
local RandomPool = require(ReplicatedStorage.Shared.RandomPool)
local StateReplicator = require(ServerStorage.Server.StateReplicator)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local GameStateMachine = require(ServerStorage.Server.GameStateMachine)

local logger = CreateLogger(script)

local USE_TEST_PRODUCTS = false
local TEST_PRODUCTS = {
    -- {
    --     -- Werewolf animation pack
    --     id = 32,
    --     itemType = "Bundle",
    --     price = 500
    -- },

    -- {
    --     -- Sun Kissed Freckles (dynamic head)
    --     id = 964,
    --     itemType = "Bundle",
    --     price = 200
    -- },

    {
        -- Canvas Shoes - Pink (bundle of shoes)
        id = 877,
        itemType = "Bundle",
        price = 50
    },
}

local function MakeProductPools()
    local productPools = {}

    for category, productIds in AvatarShopData do
        if USE_TEST_PRODUCTS then
            productIds = TEST_PRODUCTS
        end

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
    local guessStateContainer = BasicStateContainer.new()
    StateReplicator(NetworkNamespaces.GUESS_STATE_CONTAINER, guessStateContainer)

    if USE_TEST_PRODUCTS then
        logger.warn("Test products are being used.")
    end

    productPools = MakeProductPools()

    local function RunGame()
        logger.print("Running game")
        return GameStateMachine.new(
            roundStateContainer,
            scoreStateContainer,
            guessStateContainer,
            productPools
        ):Start(function()
            logger.print("Starting a new game")
            task.spawn(RunGame)
        end)
    end

    RunGame()
end

return GameManager