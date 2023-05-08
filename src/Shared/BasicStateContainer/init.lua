local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Packages.Signal)

-- A constant that denotes that a value should be nil
local NONE = newproxy(true)

-- A simple immutable state container
local BasicStateContainer = {}
BasicStateContainer.__index = BasicStateContainer
BasicStateContainer.onStateChanged = nil :: typeof(Signal.new())
BasicStateContainer.NONE = NONE
BasicStateContainer.FusionUtil = require(script.FusionUtil)

function BasicStateContainer.new(defaultState)
    local self = setmetatable({}, BasicStateContainer)
    self._currentState = defaultState or {}
    self._observers = {}
    self.onStateChanged = Signal.new()
    return self
end

function BasicStateContainer:Observe(callback: (oldState: any, newState: any) -> ())
    local observerKey = {}
    self._observers[observerKey] = callback

    task.spawn(function()
        if self._observers[observerKey] then
            callback({}, self._currentState)
        end
    end)

    return function()
        self._observers[observerKey] = nil
    end
end

function BasicStateContainer:Patch(patch)
    local oldState = self._currentState
    local newState = table.clone(self._currentState)

    for key, value in patch do
        newState[key] = if value == NONE then nil else value
    end

    self._currentState = newState
    self.onStateChanged:Fire(oldState, newState)
    self:_fireObservers(oldState, newState)

    return newState
end

function BasicStateContainer:Clear()
    local oldState = self._currentState
    local newState = {}
    self._currentState = newState
    self.onStateChanged:Fire(oldState, newState)
    self:_fireObservers(oldState, newState)
end

function BasicStateContainer:_fireObservers(oldState, newState)
    for key, callback in self._observers do
        task.spawn(function()
            if self._observers[key] then
                callback(oldState, newState)
            end
        end)
    end
end

function BasicStateContainer:GetAll()
    return table.clone(self._currentState)
end

function BasicStateContainer:Get(key: any, defaultValue: any?)
    local result = self._currentState[key]
    return if result == nil then defaultValue else result
end

return BasicStateContainer