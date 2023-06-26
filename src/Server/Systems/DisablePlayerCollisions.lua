local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local PLAYER_GROUP = "Players"

local function DisablePlayerCollisions()
    if not PhysicsService:IsCollisionGroupRegistered(PLAYER_GROUP) then
        PhysicsService:RegisterCollisionGroup(PLAYER_GROUP)
    end

    PhysicsService:CollisionGroupSetCollidable(PLAYER_GROUP, PLAYER_GROUP, false)

    local stopObserver = Observers.observeCharacter(function(_, character)
        local function HandleChild(child: Instance)
            if child:IsA("BasePart") then
                child.CollisionGroup = PLAYER_GROUP
            end
        end

        local childConnection = character.ChildAdded:Connect(HandleChild)

        for _, child in character:GetChildren() do
            HandleChild(child)
        end

        return function()
            childConnection:Disconnect()
        end
    end)

    return stopObserver
end

return DisablePlayerCollisions