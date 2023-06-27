local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

local BasicStateContainer = require(ReplicatedStorage.Shared.BasicStateContainer)
local StateReplicator = IS_SERVER and require(ServerStorage.Server.StateReplicator)
local StateReceiver = IS_CLIENT and require(ReplicatedStorage.Client.StateReceiver)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)

local function Setup(namespace: string, defaultState: {}?)
    if IS_CLIENT then
        return StateReceiver(namespace)
    else
        local stateContainer = BasicStateContainer.new(defaultState)
        StateReplicator(namespace, stateContainer)
        return stateContainer
    end
end

return {
    guessStateContainer = Setup(NetworkNamespaces.GUESS_STATE_CONTAINER),
    idleStateContainer = Setup(NetworkNamespaces.IDLE_STATE_CONTAINER),
    matchStateContainer = Setup(NetworkNamespaces.MATCH_STATE_CONTAINER),
    productFeedStateContainer = Setup(NetworkNamespaces.PRODUCT_FEED_STATE_CONTAINER),
    roundStateContainer = Setup(NetworkNamespaces.ROUND_STATE_CONTAINER),
    scoreStateContainer = Setup(NetworkNamespaces.SCORE_STATE_CONTAINER)
}