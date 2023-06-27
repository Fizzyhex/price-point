local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local Red = require(ReplicatedStorage.Packages.Red)

local function IdleReplication()
    local network = Red.Client(NetworkNamespaces.IDLE_REPLICATION)

    UserInputService.WindowFocusReleased:Connect(function()
        network:Fire("Idle", true)
    end)

    UserInputService.WindowFocused:Connect(function()
        network:Fire("Idle", false)
    end)
end

return IdleReplication