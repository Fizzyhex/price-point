local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreEvent = require(ReplicatedStorage.Shared.Util.CoreEvent)

local GameStateChannel = {}

GameStateChannel.RaisePriceRevealBegun, GameStateChannel.ObservePriceRevealBegun = CoreEvent()
GameStateChannel.RaisePriceRevealEnded, GameStateChannel.ObservePriceRevealEnded = CoreEvent()
GameStateChannel.RaiseGameOver, GameStateChannel.ObserveGameOver = CoreEvent()

return GameStateChannel