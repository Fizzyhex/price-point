local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ToggleGroup = require(ReplicatedStorage.Client.UI.Components.ToggleGroup)

return function(target)
    local ui = ToggleGroup {
        Parent = target,
        Options = {
            { dark = "Dark" },
            { light = "Light" },
            { awesome = "Awesome"}
        }
    }

    return function()
        ui:Destroy()
    end
end