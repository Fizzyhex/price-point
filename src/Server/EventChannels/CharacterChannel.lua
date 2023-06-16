local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreEvent = require(ReplicatedStorage.Shared.Util.CoreEvent)

local ServerGameStateChannel = {}

ServerGameStateChannel.RaiseTeleportBegun, ServerGameStateChannel.ObserveTeleportBegun = CoreEvent()

return ServerGameStateChannel