local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreEvent = require(ReplicatedStorage.Shared.Util.CoreEvent)

local ItemModelChannel = {}

ItemModelChannel.RaiseItemChanged, ItemModelChannel.ObserveItemChanged = CoreEvent()

return ItemModelChannel