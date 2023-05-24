local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Packages.Red).Bin

local ANCESTORS = { workspace }
local LOCAL_PLAYER = Players.LocalPlayer
local STAGE_CAMERA_OFFSET = Vector3.new(0, 2, 0)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)
local offsetGoals = { CameraOffset = STAGE_CAMERA_OFFSET }
local offsetResetGoals = { CameraOffset = Vector3.zero }

-- Enables a GUI when the trigger is entered by the local player.
local function CameraOffsetZone()
    return Observers.observeTag("ScreenTrigger", function(zone: BasePart)
        local binAdd, binEmpty = Bin()

        local function EnableScreen()

        end

        local function DisableScreen()

        end

        local function OnTouched(touched: BasePart)
            if touched.Name ~= "HumanoidRootPart" then
                return
            end

            if touched.Parent ~= LOCAL_PLAYER.Character then
                return
            end

            local humanoid = touched.Parent:FindFirstChildWhichIsA("Humanoid")

            if humanoid and humanoid.Health > 0 then
                EnableScreen()
            end
        end

        local function OnTouchEnded(touched: BasePart)
            if touched.Name ~= "HumanoidRootPart" then
                return
            end

            if touched.Parent == LOCAL_PLAYER.Character then
                DisableScreen()
            end
        end

        binAdd(zone.Touched:Connect(OnTouched))
        binAdd(zone.TouchEnded:Connect(OnTouchEnded))
        binAdd(DisableScreen)

        return function()
            binEmpty()
        end
    end, ANCESTORS)
end

return CameraOffsetZone