local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FOLDER_NAME = "ReplicationBin"

local function GetReplicationBin()
    if RunService:IsClient() then
        return ReplicatedStorage:WaitForChild(FOLDER_NAME)
    else
        local bin = ReplicatedStorage:FindFirstChild(FOLDER_NAME)

        if bin then
            return bin
        end

        bin = Instance.new("Folder")
        bin.Name = FOLDER_NAME
        bin.Parent = ReplicatedStorage

        return bin
    end
end

return GetReplicationBin