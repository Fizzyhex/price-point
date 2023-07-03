local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Red = require(ReplicatedStorage.Packages.Red)

local function CharacterTeleporter()
    local network = Red.Client("Character")
    network:On("Teleport", function(cframe: CFrame)
        local character = Players.LocalPlayer.Character
        local humanoid: Humanoid = character:FindFirstChildWhichIsA("Humanoid")

        if humanoid.Sit then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            -- Seats seem to get teleported with the player a lot of the time otherwise...
            task.wait()
        end

        character:PivotTo(cframe)
    end)
end

return CharacterTeleporter