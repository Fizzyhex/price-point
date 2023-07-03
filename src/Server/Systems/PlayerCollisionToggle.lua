local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)

local function PlayerCollisionToggle()
    local network = Red.Server(NetworkNamespaces.COLLISIONS)

    network:On("Toggle", function(player: Player, enabled: boolean?)
        enabled = enabled == true
        player:SetAttribute("canCollide", enabled)
    end)
end

return PlayerCollisionToggle