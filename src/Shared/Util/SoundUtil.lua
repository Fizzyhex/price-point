local SoundService = game:GetService("SoundService")

local soundGroups = SoundService.SoundGroups

local SoundUtil = {}

function SoundUtil.FindSoundGroup(name: string): SoundGroup?
    return soundGroups:FindFirstChild(name, true)
end

return SoundUtil