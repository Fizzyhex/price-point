local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value

local function Valueify(thing)
    if typeof(thing) == "table" and thing.type == "State" then
        return thing
    else
        return Value(thing)
    end
end

return Valueify