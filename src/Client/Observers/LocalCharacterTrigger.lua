local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)

local ANCESTORS = { workspace }
local LOCAL_PLAYER = Players.LocalPlayer

local channels = { ZoneTriggerChannel = require(ReplicatedStorage.Client.EventChannels.ZoneTriggerChannel) }

-- Enables a GUI when the trigger is entered by the local player.
local function LocalCharacterTrigger()
    return Observers.observeTag("LocalCharacterTrigger", function(zone: BasePart)
        local binAdd, binEmpty = Bin()
        local onEnterRaisers: Folder = zone:WaitForChild("OnEnter")
        local onExitRaisers: Folder = zone:WaitForChild("OnExit")
        local isInZone = false

        local function RaiseEvents(container: Folder, ...)
            local raisers = {}

            for _, child: Instance in container:GetChildren() do
                local channelName = child:GetAttribute("channel")
                local eventName = child:GetAttribute("event")
                local channel = channels[channelName]
                local raiseEvent = channel[eventName]
                raiseEvent(child.Value, child:GetAttributes())
            end

            return raisers
        end

        local function OnExit()
            if not isInZone then
                return
            end

            isInZone = false
            print(LOCAL_PLAYER.Character.HumanoidRootPart:GetTouchingParts())
            RaiseEvents(onExitRaisers)
        end

        local function OnEnter()
            if isInZone then
                return
            end

            isInZone = true
            RaiseEvents(onEnterRaisers)
        end

        local function OnTouched(touched: BasePart)
            if not LOCAL_PLAYER.Character then
                return
            end

            if touched.Name ~= "HumanoidRootPart" then
                return
            end

            if touched.Parent ~= LOCAL_PLAYER.Character then
                return
            end

            local humanoid = touched.Parent:FindFirstChildWhichIsA("Humanoid")

            if humanoid and humanoid.Health > 0 then
                OnEnter()
            end
        end

        local function OnTouchEnded(touched: BasePart)
            if not LOCAL_PLAYER.Character then
                return
            end

            if touched.Name ~= "HumanoidRootPart" then
                return
            end

            if touched.Parent ~= LOCAL_PLAYER.Character then
                return
            end

            local humanoidRootPart: BasePart = LOCAL_PLAYER.Character:FindFirstChild("HumanoidRootPart")

            if not humanoidRootPart then
                return
            end

            for _, part in humanoidRootPart:GetTouchingParts() do
                if part == zone then
                    return
                end
            end

            OnExit()
        end

        binAdd(zone.Touched:Connect(OnTouched))
        binAdd(zone.TouchEnded:Connect(OnTouchEnded))
        binAdd(OnExit)
        zone.LocalTransparencyModifier = 1

        return function()
            zone.LocalTransparencyModifier = 0
            binEmpty()
        end
    end, ANCESTORS)
end

return LocalCharacterTrigger