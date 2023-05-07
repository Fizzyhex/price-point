local FusionUtil = {}

-- Ties a Fusion `Value` object to a `StateContainer` key
function FusionUtil.StateHook<stateObject>(stateContainer, state: stateObject, key: string): (RBXScriptConnection, stateObject)
    do
        local initalValue = stateContainer:Get(key)

        if initalValue ~= nil then
            state:set(initalValue)
        end
    end

    return stateContainer.onStateChanged:Connect(function(_, new)
        if new[key] then
            state:set(if new[key] == stateContainer.NONE then nil else new[key])
        end
    end), state
end

return FusionUtil