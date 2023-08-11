local random = Random.new()

type PlayRandomSound = (sounds: {Sound}) -> () & (container: Instance) -> ()

local PlayRandomSound: PlayRandomSound = function(sounds)
    if typeof(sounds) == "Instance" then
        sounds = sounds:GetChildren()
    end

    task.spawn(function()
        sounds[random:NextInteger(1, #sounds)]:Play()
    end)
end

return PlayRandomSound