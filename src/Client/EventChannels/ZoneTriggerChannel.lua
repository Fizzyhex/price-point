local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CoreEvent = require(ReplicatedStorage.Shared.Util.CoreEvent)

local ZoneTriggerChannel = {}

ZoneTriggerChannel.RaiseScreenTriggerEnter, ZoneTriggerChannel.ObserveScreenTriggerEnter = CoreEvent()
ZoneTriggerChannel.RaiseScreenTriggerExit, ZoneTriggerChannel.ObserveScreenTriggerExit = CoreEvent()

ZoneTriggerChannel.RaiseCameraTriggerEnter, ZoneTriggerChannel.ObserveCameraTriggerEnter = CoreEvent()
ZoneTriggerChannel.RaiseCameraTriggerExit, ZoneTriggerChannel.ObserveCameraTriggerExit = CoreEvent()

return ZoneTriggerChannel