local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local CharacterChannel = require(ServerStorage.Server.EventChannels.CharacterChannel)
local Red = require(ReplicatedStorage.Packages.Red)

local function CharacterTeleportSender()
    local namespace = Red.Server("Character")

    CharacterChannel.ObserveTeleportBegun(function(character: Model, cframe: CFrame)
        local player = Players:GetPlayerFromCharacter(character)

        if player then
            namespace:Fire(player, "Teleport", cframe)
        end
    end)
end

return CharacterTeleportSender