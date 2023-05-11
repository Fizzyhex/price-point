local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
    },

    observerPaths = {
        ServerStorage.Server.Observers
    }
})

if RunService:IsStudio() then
    local tagList = ServerStorage:FindFirstChild("TagList")

    if tagList then
        -- Allows CollectionService tags to appear in the TagEditor on the client
        tagList.Parent = ReplicatedStorage
    end
end

print("✅ Server started!")