local SoundService = game:GetService("SoundService")

local soundGroups = SoundService.SoundGroups

local SoundUtil = {}

function SoundUtil.FindSoundGroup(name: string): SoundGroup?
    return soundGroups:FindFirstChild(name, true)
end

function SoundUtil.WaitForSoundGroup(name: string): SoundGroup?
    return soundGroups:WaitForChild("Game"):WaitForChild(name)
end

return SoundUtil