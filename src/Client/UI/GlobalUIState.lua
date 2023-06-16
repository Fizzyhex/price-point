local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Spring = Fusion.Spring
local Computed = Fusion.Computed

local GlobalUIState = {}

GlobalUIState.TouchButtonSize = Spring(Computed(function()
    
end))

return GlobalUIState