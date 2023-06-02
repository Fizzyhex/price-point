local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ZoneTriggerChannel = require(ReplicatedStorage.Client.EventChannels.ZoneTriggerChannel)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

-- Toggles a SurfaceGui when a trigger is entered/exited.
local function ScreenTriggerListener()
    local logger = CreateLogger(script)

    local function Toggle(instance: Instance, isEnabled: boolean)
        if instance:IsA("SurfaceGui") then
            instance.Enabled = isEnabled
        else
            instance.Visible = isEnabled
        end
    end

    ZoneTriggerChannel.ObserveScreenTriggerEnter(function(screen: SurfaceGui)
        logger.assert(screen, "ScreenTrigger does not point to an instance")
        Toggle(screen, true)
        local part = screen:FindFirstAncestorWhichIsA("BasePart")
        local sound: Sound = part and part:FindFirstChild("ScreenShowSound")

        if sound then
            sound:Play()
        end
    end)

    ZoneTriggerChannel.ObserveScreenTriggerExit(function(screen: SurfaceGui)
        logger.assert(screen, "ScreenTrigger does not point to an instance")
        Toggle(screen, false)
        local part = screen:FindFirstAncestorWhichIsA("BasePart")
        local sound: Sound = part and part:FindFirstChild("ScreenHideSound")

        if sound then
            sound:Play()
        end
    end)
end

return ScreenTriggerListener