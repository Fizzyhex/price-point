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
    end)

    ZoneTriggerChannel.ObserveScreenTriggerExit(function(screen: SurfaceGui)
        logger.assert(screen, "ScreenTrigger does not point to an instance")
        Toggle(screen, false)
    end)
end

return ScreenTriggerListener