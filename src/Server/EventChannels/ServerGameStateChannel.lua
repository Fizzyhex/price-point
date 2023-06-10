local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreEvent = require(ReplicatedStorage.Shared.Util.CoreEvent)

local ServerGameStateChannel = {}

ServerGameStateChannel.RaisePriceRevealBegun, ServerGameStateChannel.ObservePriceRevealBegun = CoreEvent()
ServerGameStateChannel.RaisePriceRevealEnded, ServerGameStateChannel.ObservePriceRevealEnded = CoreEvent()
ServerGameStateChannel.RaiseGameOver, ServerGameStateChannel.ObserveGameOver = CoreEvent()
ServerGameStateChannel.RaiseRoundOver, ServerGameStateChannel.ObserveRoundOver = CoreEvent()

return ServerGameStateChannel