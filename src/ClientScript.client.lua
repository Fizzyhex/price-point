local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Start = require(ReplicatedStorage.Shared.Start)

Start({
    systemPaths = {
        ReplicatedStorage.Client.Systems,
        ReplicatedStorage.Shared.Systems
    },

    observerPaths = {
        ReplicatedStorage.Client.Observers,
    },

    componentPaths = {
        ReplicatedStorage.Client.Components,
        ReplicatedStorage.Shared.Components
    }
})

print("✅ Client started!")