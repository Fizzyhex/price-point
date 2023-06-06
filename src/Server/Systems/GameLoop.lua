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

local STATE_CONTAINER_NAMESPACES = {
    roundStateContainer = NetworkNamespaces.ROUND_STATE_CONTAINER,
    ProductFeedStateContainer = NetworkNamespaces.PRODUCT_FEED_STATE_CONTAINER,
    scoreStateContainer = NetworkNamespaces.SCORE_STATE_CONTAINER,
    guessStateContainer = NetworkNamespaces.GUESS_STATE_CONTAINER
}

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

    -- {
    --     -- Canvas Shoes - Pink (shoes bundle)
    --     id = 877,
    --     itemType = "Bundle",
    --     price = 50
    -- },

    -- {
    --     -- Trim (head)
    --     id = 6340227,
    --     itemType = "Asset",
    --     price = 0
    -- },

    {
        -- I feel Bricky 2 (pants)
        id = 23571257,
        itemType = "Asset",
        price = 50
    }
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

local GameLoop = {}

function GameLoop:OnStart()
    logger.print("Starting game state machine...")
    local productPools = MakeProductPools()
    local stateContainers = {}

    for key, networkNamespace in STATE_CONTAINER_NAMESPACES do
        local stateContainer = BasicStateContainer.new()
        stateContainers[key] = stateContainer
        StateReplicator(networkNamespace, stateContainer)
    end

    if USE_TEST_PRODUCTS then
        logger.warn("Test products are being used.")
    end

    productPools = MakeProductPools()

    local function RunGame()
        logger.print("Running game")
        return GameStateMachine.new(
            stateContainers,
            productPools
        ):Start(function()
            logger.print("Starting a new game")
            task.spawn(RunGame)
        end)
    end

    RunGame()
end

return GameLoop