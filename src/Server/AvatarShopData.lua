local ServerStorage = game:GetService("ServerStorage")
local export = {}
local start = tick()

local function RoundNumber(number, dp)
    local division = 10 ^ dp
    return math.round(number * division) / division
end

for _, moduleScript: ModuleScript in ServerStorage.ScrapeExports:GetChildren() do
    local data = require(moduleScript)
    export[moduleScript.Name] = data
end

local timeElapsed = tick() - start
print(`Compiled AvatarShopData ({RoundNumber(timeElapsed, 5)}s)`)

return export