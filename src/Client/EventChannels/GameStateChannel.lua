local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreEvent = require(ReplicatedStorage.Shared.Util.CoreEvent)

local GameStateChannel = {}

GameStateChannel.RaisePriceRevealBegun, GameStateChannel.ObservePriceRevealBegun = CoreEvent()
GameStateChannel.RaisePriceRevealEnded, GameStateChannel.ObservePriceRevealEnded = CoreEvent()
GameStateChannel.RaisePriceAnimationEnded, GameStateChannel.ObservePriceAnimationEnded = CoreEvent()
GameStateChannel.RaiseGameOver, GameStateChannel.ObserveGameOver = CoreEvent()
GameStateChannel.RaiseRoundOver, GameStateChannel.ObserveRoundOver = CoreEvent()

return GameStateChannel