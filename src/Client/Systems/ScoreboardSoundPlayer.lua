local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ScoreboardChannel = require(ReplicatedStorage.Client.EventChannels.ScoreboardChannel)

local function ScoreboardSoundPlayer()
    local function FindScoreboardSound(scoreboard, soundName: string): Sound?
        local primaryPart: BasePart? = scoreboard.PrimaryPart
        local sound: Sound? = primaryPart and primaryPart:FindFirstChild(soundName)

        if sound then
            return sound
        end
    end

    local stopListeningForSounds = ScoreboardChannel.ObserveScoreboardResort(function(scoreboard)
        local sound = FindScoreboardSound(scoreboard, "ResortSound")

        if sound then
            task.wait(0.1)
            sound:Play()
        end
    end)

    return function()
        stopListeningForSounds()
    end
end

return ScoreboardSoundPlayer