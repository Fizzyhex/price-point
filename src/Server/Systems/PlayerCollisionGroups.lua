local PhysicsService = game:GetService("PhysicsService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)

local PLAYER_GROUP = "Players"
local PLAYER_PHASE_GROUP = "PlayersNoColl"

local function DisablePlayerCollisions()
    if not PhysicsService:IsCollisionGroupRegistered(PLAYER_GROUP) then
        PhysicsService:RegisterCollisionGroup(PLAYER_GROUP)
    end

    if not PhysicsService:IsCollisionGroupRegistered(PLAYER_PHASE_GROUP) then
        PhysicsService:RegisterCollisionGroup(PLAYER_PHASE_GROUP)
    end

    PhysicsService:CollisionGroupSetCollidable(PLAYER_GROUP, PLAYER_PHASE_GROUP, false)

    local function GetCollisionGroup(player: Player)
        return if player:GetAttribute("CanCollide") == false then PLAYER_PHASE_GROUP else PLAYER_GROUP
    end

    local stopObserver = Observers.observeCharacter(function(player, character)
        local binAdd, binEmpty = Bin()

        local function HandleChild(child: Instance, group: string?)
            local collisionGroup = group or GetCollisionGroup(player)

            if child:IsA("BasePart") then
                child.CollisionGroup = collisionGroup
            end
        end

        local function UpdateAll()
            local group = GetCollisionGroup(player)

            for _, child in character:GetChildren() do
                HandleChild(child, group)
            end
        end

        binAdd(character.ChildAdded:Connect(HandleChild))
        UpdateAll()

        binAdd(Observers.observeAttribute(player, "canCollide", function()
            UpdateAll()
            return UpdateAll
        end))

        return binEmpty
    end)

    return stopObserver
end

return DisablePlayerCollisions