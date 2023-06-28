local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local Red = require(ReplicatedStorage.Packages.Red)

local function ClientIdleReplication()
    local network = Red.Client(NetworkNamespaces.IDLE_REPLICATION)

    UserInputService.WindowFocusReleased:Connect(function()
        network:Fire("Afk", true)
    end)

    UserInputService.WindowFocused:Connect(function()
        network:Fire("Afk", false)
    end)
end

return ClientIdleReplication