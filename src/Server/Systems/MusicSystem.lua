local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ServerGameStateChannel = require(ServerStorage.Server.EventChannels.ServerGameStateChannel)
local RandomPool = require(ReplicatedStorage.Shared.RandomPool)
local SoundUtil = require(ReplicatedStorage.Shared.Util.SoundUtil)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)

local tracksFolder = ReplicatedStorage.Assets.BackgroundMusic
local logger = CreateLogger(script)

local function MusicSystem()
    local binAdd, binEmpty = Bin()
    local musicPool = RandomPool.new(tracksFolder:GetChildren())
    local musicSoundGroup = SoundUtil.FindSoundGroup("Music")
    local currentTrack

    local function PlayTrack(sound: Sound)
        if currentTrack then
            currentTrack:Stop()
        end

        currentTrack = sound
        sound.SoundGroup = musicSoundGroup
        logger.print("🎵 Now playing:", sound)
        sound:Play()
    end

    local function OnMusicEvent()
        if currentTrack and currentTrack.IsPlaying then
            return
        end

        task.spawn(PlayTrack, musicPool:Pop())
    end

    binAdd(ServerGameStateChannel.ObserveIntermissionBegun(OnMusicEvent))
    binAdd(ServerGameStateChannel.ObserveNewRound(OnMusicEvent))
    return binEmpty
end

return MusicSystem