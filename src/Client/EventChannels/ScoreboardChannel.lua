local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreEvent = require(ReplicatedStorage.Shared.Util.CoreEvent)

local ZoneTriggerChannel = {}

ZoneTriggerChannel.RaiseScoreboardResort, ZoneTriggerChannel.ObserveScoreboardResort = CoreEvent()

return ZoneTriggerChannel