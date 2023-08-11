local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Observers = require(ReplicatedStorage.Packages.Observers)

local crossfade = TweenInfo.new(4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function Ambience()
    local dayTrack = SoundService:WaitForChild("Ambience"):WaitForChild("Day")
    local nightTrack = SoundService:WaitForChild("Ambience"):WaitForChild("Night")
    local lastTrack
    
    local function crossfadeToTrack(track)
        if lastTrack == track then
            return
        end

        if lastTrack then
            TweenService:Create(track, crossfade, { Volume = 0 }):Play()
        end

        TweenService:Create(track, crossfade, { Volume = 0.5 }):Play()
        lastTrack = track
        track:Play()
    end

    Observers.observeProperty(Lighting, "ClockTime", function(clockTime)
        if clockTime > 9 and clockTime < 19 then
            crossfadeToTrack(dayTrack)
        else
            crossfadeToTrack(nightTrack)
        end

        return function() end
    end)
end

return Ambience