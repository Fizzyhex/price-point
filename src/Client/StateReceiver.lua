local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BasicStateContainer = require(ReplicatedStorage.Shared.BasicStateContainer)
local Red = require(ReplicatedStorage.Packages.Red)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local logger = CreateLogger(script)

local function StateReceiver(namespace: string)
    local network = Red.Client(namespace)
    local stateContainer = BasicStateContainer.new()

    network:On("Replicate", function(data)
        if next(data) == nil and next(stateContainer:GetAll()) ~= nil then
            stateContainer:Clear()
            return
        end

        local payload = {}

        for key, valueContainer in data do
            local value = valueContainer[1]
            payload[key] = if value == nil then BasicStateContainer.NONE else value
        end

        stateContainer:Patch(payload)
    end)

    return stateContainer
end

return StateReceiver