local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreEvent = require(ReplicatedStorage.Shared.Util.CoreEvent)

local GameStateChannel = {}

GameStateChannel.RaisePriceRevealed, GameStateChannel.ObservePriceRevealed = CoreEvent()

return GameStateChannel