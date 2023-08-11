local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local SoundUtil = require(ReplicatedStorage.Shared.Util.SoundUtil)
local ClientSettings = require(ReplicatedStorage.Client.State.ClientSettings)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Value = Fusion.Value
local Spring = Fusion.Spring
local Hydrate = Fusion.Hydrate
local Computed = Fusion.Computed

local crossfade = TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function MusicPlayer()
    local playQuietly = Value(false)
    local volumeGoal = Computed(function()
        local value = ClientSettings.MusicVolume.value:get() / 100

        if playQuietly:get() then
            value /= 2
        end

        return value
    end)

    local volumeSpring = Spring(volumeGoal, 15)
    local musicSoundGroup = SoundUtil.WaitForSoundGroup("Music")

    Hydrate(musicSoundGroup) {
        Volume = volumeSpring
    }

    local function FindTrack(guid)
        for _, child in ReplicatedStorage.Assets.Music:GetDescendants() do
            if child:IsA("Sound") and child:GetAttribute("GUID") == guid then
                return child
            end
        end

        return nil
    end

    Observers.observeAttribute(SoundService, "CurrentTrack", function(trackName)
        assert(typeof(trackName) == "string", "SoundService attribute 'CurrentTrack' is of a non-string type")
        local track = FindTrack(trackName)

        if track then
            if track:GetAttribute("BaseVolume") == nil then
                track:GetAttributeChangedSignal("BaseVolume"):Wait()
            end

            local baseVolume = track:GetAttribute("BaseVolume")
            track.Volume = 0

            TweenService:Create(track, crossfade, { Volume = baseVolume }):Play()
        end
        
        return function()
            TweenService:Create(track, crossfade, { Volume = 0 }):Play()
        end
    end)
end

return MusicPlayer