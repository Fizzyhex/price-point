local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local Red = require(ReplicatedStorage.Packages.Red)

local function ServerIdleReplication()
    local network = Red.Server(NetworkNamespaces.IDLE_REPLICATION)

    network:On("Afk", function(player: Player, isAfk: boolean)
        isAfk = (isAfk == true)
        player:SetAttribute("isAfk", isAfk)
    end)
end

return ServerIdleReplication