local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SoundUtil = require(ReplicatedStorage.Shared.Util.SoundUtil)
local MusicController = {}

local function GetGUID(track: Instance)
    local guid = track:GetAttribute("GUID")

    if guid then
        return guid
    else
        guid = HttpService:GenerateGUID()
        track:SetAttribute("GUID", guid)
        return guid
    end
end

local function PlayTrack(track)
    if track:GetAttribute("BaseVolume") == nil then
        track:SetAttribute("BaseVolume", track.Volume)
    end

    track.SoundGroup = SoundUtil.FindSoundGroup("Music")
    track.Volume = 0
    track:Play()
end

function MusicController.SetCategory(categoryName)
    local category = ReplicatedStorage.Assets.Music:FindFirstChild(categoryName)

    if category == nil then
        warn(`Music category '{categoryName}' not found`)
        return
    end

    local tracks = {}

    for _, track in category:GetChildren() do
        table.insert(tracks, track)

        if track.IsPlaying then
            SoundService:SetAttribute("CurrentTrack", GetGUID(track))
            return
        end
    end

    if #tracks == 0 then
        warn(`Music category '{categoryName}' is empty`)
        return
    end

    local track = tracks[math.random(1, #tracks)]
    PlayTrack(track)
end

function MusicController.FadeOutMusic()
    SoundService:SetAttribute("CurrentTrack", nil)
end

function MusicController.QuietenMusic()
    SoundService:SetAttribute("MusicQuiet", true)
end

function MusicController.LoudenMusic()
    SoundService:SetAttribute("MusicQuiet", nil)
end

for _, child in ReplicatedStorage.Assets.Music:GetDescendants() do
    if child:IsA("Sound") then
        GetGUID(child)
    end
end

return MusicController