local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local LOCAL_PLAYER = Players.LocalPlayer
local DEATH_FORCE_MIN, DEATH_FORCE_MAX = 20, 40
local RANDOM = Random.new()

local function ClientDeathPhysics()
    return Observers.observeCharacter(function(player, character)
        if LOCAL_PLAYER ~= player then
            return
        end

        local humanoidListener, deathListener

        local function HandleHumanoid(humanoid: Humanoid)
            deathListener = humanoid.Died:Connect(function()
                local rootPart = humanoid.RootPart

                if rootPart then
                    rootPart.AssemblyAngularVelocity -=
                        rootPart.CFrame.LookVector
                        * RANDOM:NextNumber(DEATH_FORCE_MIN, DEATH_FORCE_MAX)
                end
            end)
        end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")

        if humanoid then
            HandleHumanoid(humanoid)
        else
            humanoidListener = character.ChildAdded:Connect(function(child)
                if child:IsA("Humanoid") then
                    humanoidListener:Disconnect()
                    HandleHumanoid(child)
                end
            end)
        end

        return function()
            if humanoidListener then
                humanoidListener:Disconnect()
            end

            if deathListener then
                deathListener:Disconnect()
            end
        end
    end)
end

return ClientDeathPhysics