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
        type = "Toggle",
        id = kwargs.id,
        displayName = kwargs.displayName,
        options = kwargs.options,
        value = Fusion.Value(kwargs.defaultValue)
    }
end

local function CreateDefaultSettings()
    local clientSettings = {}

    clientSettings.MusicVolume = NumberRangeSetting({
        id = "MusicVolume",
        displayName = "Music Volume",
        min = 0,
        max = 100,
        defaultValue = 50
    })

    clientSettings.Theme = ToggleSetting({
        id = "Theme",
        displayName = "Theme",
        defaultValue = "dark",
        options = { light = "Light", dark = "Dark" }
    })

    return clientSettings
end

return CreateDefaultSettings