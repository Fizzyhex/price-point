local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Observers = require(ReplicatedStorage.Packages.Observers)

local GameStateChannel = require(ReplicatedStorage.Client.EventChannels.GameStateChannel)

local ANCESTORS = { workspace }
local TWEEN_OUT_DURATION = 0.25

-- A light that flashes when the round ends
local function RoundEndLight()
    local stopObservingTag = Observers.observeTag("RoundEndLight", function(light: Light)
        local wasOriginallyEnabled = light.Enabled
        local brightness = light.Brightness
        light.Brightness = 0
        light.Enabled = true
        local tweenTask

        local function DoFlash()
            light.Brightness = brightness

            if tweenTask then
                task.cancel(tweenTask)
            end

            task.delay(TWEEN_OUT_DURATION, function()
                local tweenInfo = TweenInfo.new(
                    TWEEN_OUT_DURATION,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )
                local tween = TweenService:Create(light, tweenInfo, { Brightness = 0 })
                tween:Play()
            end)
        end

        local stopListeningForRoundEnd = GameStateChannel.ObserveRoundOver(DoFlash)
        local stopListeningForDebug = Observers.observeAttribute(light, "DebugFlash", function(value)
            if value then
                light:SetAttribute("DebugFlash", false)
                print("Flashing at brightness", brightness)
                task.spawn(DoFlash)
            end

            return function() end
        end)

        light:SetAttribute("DebugFlash", false)

        return function()
            light.Enabled = wasOriginallyEnabled
            light.Brightness = brightness
            light:SetAttribute("DebugFlash", nil)
            stopListeningForRoundEnd()
            stopListeningForDebug()

            if tweenTask then
                task.cancel(tweenTask)
            end
        end
    end, ANCESTORS)

    return stopObservingTag
end

return RoundEndLight