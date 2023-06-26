local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)
local ClientSettings = require(ReplicatedStorage.Client.State.ClientSettings)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local function ClientPlayerCollisions()
    local playerCollisionsEnabled = ClientSettings.PlayerCollisionsEnabled.value

    return Observers.observeCharacter(function(player, character)
        if player ~= Players.LocalPlayer then
            return
        end

        local binAdd, binEmpty = Bin()

        local function Update(part: BasePart)
            part.CollisionGroup = if playerCollisionsEnabled:get() then "Default" else "Players"
        end

        local function UpdateAll()
            for _, child in character:GetChildren() do
                if child:IsA("BasePart") then
                    Update(child)
                end
            end
        end

        binAdd(character.ChildAdded:Connect(function(child: BasePart)
            if child:IsA("BasePart") then
                Update(child)
            end
        end))

        UpdateAll()
        binAdd(Fusion.Observer(playerCollisionsEnabled):onChange(UpdateAll))
        return binEmpty
    end)
end

return ClientPlayerCollisions