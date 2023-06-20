local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local function NumberRangeSetting(kwargs: {
    id: string,
    displayName: string,
    min: number,
    max: number,
    defaultValue: number?
})
    return {
        type = "NumberRange",
        id = kwargs.id,
        displayName = kwargs.displayName,
        min = kwargs.min,
        max = kwargs.max,
        value = Fusion.Value(kwargs.defaultValue or 0)
    }
end

local function ToggleSetting(kwargs: {
    id: string,
    displayName: string,
    options: {string: any},
    defaultValue: any
})
    return {
        type = "NumberRange",
        id = kwargs.id,
        displayName = kwargs.displayName,
        min = kwargs.min,
        max = kwargs.max,
        value = Fusion.Value(kwargs.defaultValue or 0)
    }
end

local function CreateDefaultSettings()
    local clientSettings = {}

    clientSettings.MusicVolume = NumberRangeSetting({
        id = "MusicVolume",
        displayName = "Music Volume",
        min = 0,
        max = 100,
        defaultValue = 25
    })

    clientSettings.Theme = ToggleSetting({
        id = "Theme",
        displayName = "Theme",
        defaultValue = "Dark",
        options = { Light = "Light", Dark = "Dark" }
    })

    return clientSettings
end

return CreateDefaultSettings