local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local function DisableBreakJointsOnDeath()
    return Observers.observeCharacter(function(_, character)
        local humanoidListener

        local function HandleHumanoid(humanoid: Humanoid)
            humanoid.BreakJointsOnDeath = false
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
        end
    end)
end

return DisableBreakJointsOnDeath