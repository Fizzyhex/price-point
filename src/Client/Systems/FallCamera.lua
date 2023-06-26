local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Observers = require(ReplicatedStorage.Packages.Observers)

local function FallCamera()
    Observers.observeCharacter(function(player, character)
        if player ~= Players.LocalPlayer then
            return
        end

        local camera = workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Custom
        local humanoidRootPart: BasePart? = character:WaitForChild("HumanoidRootPart", 20)

        if not humanoidRootPart then
            return
        end

        local function DoFallTracking()
            camera.CameraType = Enum.CameraType.Scriptable

            local runConnection
            runConnection = RunService.RenderStepped:Connect(function(delta)
                if character:IsDescendantOf(workspace) == false then
                    runConnection:Disconnect()
                    return
                end

                camera.CFrame = camera.CFrame:Lerp(
                    CFrame.lookAt(camera.CFrame.Position, humanoidRootPart.Position),
                    delta * 60 * 0.1
                )
            end)
        end

        local heartbeatConnection
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            local fallCameraHeight = workspace:GetAttribute("FallCameraHeight")

            if not fallCameraHeight then
                return
            end

            if humanoidRootPart.Position.Y < fallCameraHeight then
                DoFallTracking()
                heartbeatConnection:Disconnect()
            end
        end)

        return function()
            heartbeatConnection:Disconnect()
        end
    end)
end

return FallCamera