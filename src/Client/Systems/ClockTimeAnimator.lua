local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ClientSettings = require(ReplicatedStorage.Client.State.ClientSettings)

local function ClockTimeAnimator()
    local serverTime = Fusion.Value(Lighting:GetAttribute("ServerTime") or 0)
    local timeSetting = ClientSettings.Time
    local timeModeSetting = ClientSettings.TimeMode
    local timeSpring

    local clockTime = Fusion.Computed(function()
        if timeModeSetting.value:get() == "custom" then
            return timeSetting.value:get()
        else
            return serverTime:get()
        end
    end)

    timeSpring = Fusion.Spring(clockTime, 5)

    local function SyncServerTime(value: number)
        serverTime:set(value)
    end

    Observers.observeAttribute(Lighting, "ServerTime", SyncServerTime)
    Fusion.Observer(serverTime):onChange(function()
        -- Teleport the time spring from 24 to 0, to allow the spring to 'wrap around'.
        if serverTime:get() == 0 and timeSpring:get() >= 23.5 and timeModeSetting.value:get() == "server" then
            timeSpring:setPosition(serverTime:get())
        end
    end)

    Fusion.Hydrate(Lighting) { ClockTime = timeSpring }
end

return ClockTimeAnimator