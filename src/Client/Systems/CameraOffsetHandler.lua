local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ZoneTriggerChannel = require(ReplicatedStorage.Client.EventChannels.ZoneTriggerChannel)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Observers = require(ReplicatedStorage.Packages.Observers)

local LOCAL_PLAYER = Players.LocalPlayer
local STAGE_CAMERA_OFFSET = Vector3.new(0, 2, 0)
local TWEEN_INFO = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

-- Handles the humanoid's CameraOffset.
local function CameraOffsetHandler()
    local zoneOffset = Fusion.Value(Vector3.zero)
    local isKeyboardOpen = Fusion.Value(false)

    local cameraOffsetGoal = Fusion.Computed(function()
        local value = zoneOffset:get()

        if isKeyboardOpen then
            value *= 2.5
        end

        return value
    end)
    local cameraOffsetSpring = Fusion.Spring(cameraOffsetGoal, 10)

    local function GetHumanoid(): Humanoid?
        return LOCAL_PLAYER.Character and LOCAL_PLAYER.Character:FindFirstChildWhichIsA("Humanoid")
    end

    local function OnScreenKeyboardChanged()
        isKeyboardOpen:set(UserInputService.OnScreenKeyboardVisible)
    end

    UserInputService:GetPropertyChangedSignal("OnScreenKeyboardVisible"):Connect(OnScreenKeyboardChanged)

    ZoneTriggerChannel.ObserveCameraTriggerEnter(function(_, attributes)
        local humanoid = GetHumanoid()

        if humanoid then
            zoneOffset:set(
                if attributes and attributes.CameraOffset then attributes.CameraOffset
                else STAGE_CAMERA_OFFSET
            )
        end
    end)

    ZoneTriggerChannel.ObserveCameraTriggerExit(function()
        local humanoid = GetHumanoid()

        if humanoid then
            zoneOffset:set(Vector3.zero)
        end
    end)

    Observers.observeCharacter(function(player: Player, character: Instance)
        if player ~= LOCAL_PLAYER then
            return
        end

        local humanoid = character:WaitForChild("Humanoid", 20)

        if not humanoid then
            return
        end

        cameraOffsetSpring:setPosition(Vector3.new(0, 10, 0))

        Fusion.Hydrate(humanoid) {
            CameraOffset = cameraOffsetSpring
        }
    end)
end

return CameraOffsetHandler