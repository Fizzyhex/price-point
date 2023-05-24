local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)

local GlobalEventSystem = {}

GlobalEventSystem.onScoreboardResort = Signal.new()
GlobalEventSystem.onPriceRevealed = Signal.new()

return GlobalEventSystem