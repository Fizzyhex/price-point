local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Packages.Red).Bin

local ANCESTORS = { workspace }
local LOCAL_PLAYER = Players.LocalPlayer

local channels = {
    ZoneTriggerChannel = require(ReplicatedStorage.Client.EventChannels.ZoneTriggerChannel)
}

-- Enables a GUI when the trigger is entered by the local player.
local function LocalCharacterTrigger()
    return Observers.observeTag("LocalCharacterTrigger", function(zone: BasePart)
        local binAdd, binEmpty = Bin()
        local onEnterRaisers: Folder = zone:WaitForChild("OnEnter")
        local onExitRaisers: Folder = zone:WaitForChild("OnExit")

        local function RaiseEvents(container: Folder, ...)
            local raisers = {}

            for _, child in container:GetChildren() do
                local channelName = child:GetAttribute("channel")
                local eventName = child:GetAttribute("event")
                local channel = channels[channelName]
                local raiseEvent = channel[eventName]
                raiseEvent(child.Value, ...)
            end

            return raisers
        end

        local function OnEnter()
            RaiseEvents(onEnterRaisers)
        end

        local function OnExit()
            RaiseEvents(onExitRaisers)
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
                OnEnter()
            end
        end

        local function OnTouchEnded(touched: BasePart)
            if touched.Name ~= "HumanoidRootPart" then
                return
            end

            if touched.Parent == LOCAL_PLAYER.Character then
                OnExit()
            end
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