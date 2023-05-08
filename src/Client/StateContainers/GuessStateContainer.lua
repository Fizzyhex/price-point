local ReplicatedStorage = game:GetService("ReplicatedStorage")

local StateReceiver = require(ReplicatedStorage.Client.StateReceiver)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)

return StateReceiver(NetworkNamespaces.GUESS_STATE_CONTAINER)