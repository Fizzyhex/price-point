local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local PropsUtil = {}
PropsUtil.NIL = newproxy()

-- Takes the old props and combines them with the new ones, overwriting any existing keys and combining children.
function PropsUtil.PatchProps(oldProps, newProps)
    local result = table.clone(oldProps)

    for key, value in newProps do
        if value == PropsUtil.NIL then
            result[key] = nil
        elseif key == Fusion.Children and typeof(value) == "table" then
            for key2, value2 in value do
                table.insert(result[key2], value2)
            end
        else
            result[key] = value
        end
    end

    return result
end


return PropsUtil