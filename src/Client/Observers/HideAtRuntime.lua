local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)

local ANCESTORS = { workspace }

local function HideAtRuntime()
    Observers.observeTag("HideAtRuntime", function(part: BasePart)
        part.LocalTransparencyModifier = 1

        return function()
            part.LocalTransparencyModifier = 0
        end
    end, ANCESTORS)
end

return HideAtRuntime