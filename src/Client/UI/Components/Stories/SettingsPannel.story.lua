local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local SettingsPannel = require(ReplicatedStorage.Client.UI.Components.SettingsPannel)
local CreateDefaultSettings = require(ReplicatedStorage.Shared.Data.CreateDefaultSettings)

local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

return function(target: Instance)
    local ui = Nest {
        Parent = target,

        [Children] = {
            SettingsPannel {
                Settings = CreateDefaultSettings(),
            },
            ShorthandPadding { Padding = UDim.new(0, 12) }
        }
    }

    return function()
        ui:Destroy()
    end
end