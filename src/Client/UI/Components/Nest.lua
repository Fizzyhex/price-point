local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local New = Fusion.New

-- A parent-sized container with no background
local function Nest(props)
    local nest = New "Frame" {
        Name = "Nest",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1)
    }

    return Hydrate(nest)(props)
end

return Nest