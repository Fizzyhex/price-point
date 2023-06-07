local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BasicStateContainer = require(ReplicatedStorage.Shared.BasicStateContainer)
local Red = require(ReplicatedStorage.Packages.Red)

local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local logger = CreateLogger(script)

local function StateReplicator(namespace: string, stateContainer: typeof(BasicStateContainer.new()))
    local network = Red.Server(namespace, {"Replicate"})
    local registeredPlayers = {}

    network:On("Ready", function(player: Player)
        if registeredPlayers[player] then
            print(`{player} ({player.UserId}) requested an initial payload several times - ignoring request`)
            return
        end

        registeredPlayers[player] = true
        local data = stateContainer:GetAll()
        local payload = {}

        if next(data) == nil then
            -- Don't create an empty payload
            return
        end

        for key, value in data do
            payload[key] = {value}
        end

        logger.print(`Sending init payload to {player} for "{namespace}"`, payload)
        network:Fire(player, "Replicate", payload)
    end)

    local function OnPlayerRemoving(player: Player)
        registeredPlayers[player] = nil
    end

    stateContainer.onStateChanged:Connect(function(oldState, newState)
        if next(newState) == nil then
            -- Signal to the client to clear out the state
            network:FireAll("Replicate", {})
            return
        end

        local payload = {}

        for key, value in newState do
            if oldState[key] == value then
                continue
            end

            -- Wrap values in tables so that we can replicate nil values
            payload[key] = {value}
        end

        network:FireAll("Replicate", payload)
    end)

    for _, player in Players:GetPlayers() do
        OnPlayerRemoving(player)
    end

    Players.PlayerRemoving:Connect(OnPlayerRemoving)
end

return StateReplicator