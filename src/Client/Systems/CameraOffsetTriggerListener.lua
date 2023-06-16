local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ZoneTriggerChannel = require(ReplicatedStorage.Client.EventChannels.ZoneTriggerChannel)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local LOCAL_PLAYER = Players.LocalPlayer
local STAGE_CAMERA_OFFSET = Vector3.new(0, 2, 0)
local TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

-- Shifts the player's camera up when entered.
local function CameraOffsetTriggerListener()
    local currentTween
    local offsetGoals = { CameraOffset = STAGE_CAMERA_OFFSET }
    local offsetResetGoals = { CameraOffset = Vector3.zero }

    local function SetCurrentTween(new: Tween?)
        if currentTween then
            currentTween:Cancel()
        end

        currentTween = new
    end

    ZoneTriggerChannel.ObserveCameraTriggerEnter(function()
        local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildWhichIsA("Humanoid")

        if humanoid then
            local tween = TweenService:Create(humanoid, TWEEN_INFO, offsetGoals)
            SetCurrentTween(tween)
            tween:Play()
        end
    end)

    ZoneTriggerChannel.ObserveCameraTriggerExit(function()
        local humanoid = LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildWhichIsA("Humanoid")

        if humanoid then
            local tween = TweenService:Create(humanoid, TWEEN_INFO, offsetResetGoals)
            SetCurrentTween(tween)
            tween:Play()
        end
    end)
end

return CameraOffsetTriggerListener