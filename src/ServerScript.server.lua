local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Start = require(ReplicatedStorage.Shared.Start)

Start({
    systemPaths = {
        ServerStorage.Server.Systems,
        ReplicatedStorage.Shared.Systems,
    },

    componentPaths = {
        ServerStorage.Server.Components,
        ReplicatedStorage.Shared.Components
    }
})

print("✅ Server started!")