local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

type Setting = {
    id: string,
    displayName: string,
    layoutOrder: number?,
    enabled: any?,
}

local function NumberRangeSetting(kwargs: Setting & {
    min: number,
    max: number,
    defaultValue: number?,
    enabled: any?,
})
    return {
        type = "NumberRange",
        id = kwargs.id,
        displayName = kwargs.displayName,
        min = kwargs.min,
        max = kwargs.max,
        value = Fusion.Value(kwargs.defaultValue or 0),
        layoutOrder = kwargs.layoutOrder,
        enabled = if kwargs.enabled ~= nil then kwargs.enabled else true
    }
end

local function ToggleSetting(kwargs: Setting & {
    options: {string: any},
    defaultValue: any,
})
    return {
        type = "Toggle",
        id = kwargs.id,
        displayName = kwargs.displayName,
        options = kwargs.options,
        value = Fusion.Value(kwargs.defaultValue),
        layoutOrder = kwargs.layoutOrder,
        enabled = if kwargs.enabled ~= nil then kwargs.enabled else true
    }
end

local function CreateDefaultSettings()
    local clientSettings = {}

    clientSettings.Theme = ToggleSetting({
        id = "Theme",
        displayName = "Theme",
        defaultValue = "dark",
        options = { { light = "Light" }, { dark = "Dark" }},
        layoutOrder = 2
    })

    clientSettings.MusicVolume = NumberRangeSetting({
        id = "MusicVolume",
        displayName = "Music Volume",
        min = 0,
        max = 100,
        defaultValue = 25,
        layoutOrder = 1
    })

    clientSettings.PlayerCollisionsEnabled = ToggleSetting({
        id = "PlayerCollisions",
        displayName = "Player Collisions",
        defaultValue = true,
        options = { { [true] = "On" }, { [false] = "Off" } },
        layoutOrder = 3
    })

    clientSettings.TimeMode = ToggleSetting({
        id = "TimeMode",
        displayName = "Time",
        defaultValue = "server",
        options = { { server = "Server" }, { custom = "Custom" } },
        layoutOrder = 4
    })

    clientSettings.Time = NumberRangeSetting({
        id = "Time",
        displayName = "",
        min = 0,
        max = 24,
        defaultValue = 8,
        layoutOrder = 5,
        enabled = Fusion.Computed(function()
            return clientSettings.TimeMode.value:get() == "custom"
        end)
    })

    return clientSettings
end

return CreateDefaultSettings