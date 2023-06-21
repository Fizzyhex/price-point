local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local SoundUtil = require(ReplicatedStorage.Shared.Util.SoundUtil)
local ClientSettings = require(ReplicatedStorage.Client.State.ClientSettings)
local GameStateChannel = require(ReplicatedStorage.Client.EventChannels.GameStateChannel)
local Value = Fusion.Value
local Spring = Fusion.Spring
local Hydrate = Fusion.Hydrate
local Computed = Fusion.Computed

local logger = CreateLogger(script)

local function MusicVolumeSystem()
    local isPriceReveal = Value(false)
    local volumeGoal = Computed(function()
        local value = ClientSettings.MusicVolume.value:get() / 100

        if isPriceReveal:get() then
            value /= 2
        end

        return value
    end)

    local volumeSpring = Spring(volumeGoal, 15)
    local musicSoundGroup = SoundUtil.FindSoundGroup("Music")

    if not musicSoundGroup then
        logger.warn("MusicSoundGroup not found")
        return
    end

    GameStateChannel.ObservePriceRevealBegun(function()
        isPriceReveal:set(true)
    end)

    GameStateChannel.ObservePriceRevealEnded(function()
        isPriceReveal:set(false)
    end)

    GameStateChannel.ObservePriceAnimationEnded(function()
        isPriceReveal:set(false)
    end)

    Hydrate(musicSoundGroup) {
        Volume = volumeSpring
    }
end

return MusicVolumeSystem