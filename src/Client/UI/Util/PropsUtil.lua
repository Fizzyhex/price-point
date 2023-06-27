local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children

local PropsUtil = {}
PropsUtil.NIL = newproxy()

-- Takes the old props and combines them with the new ones, overwriting any existing keys and combining children.
--
-- Use `PropsUtil.NIL` to replace values with nil.
function PropsUtil.PatchProps(oldProps, newProps)
    local result = table.clone(oldProps)

    for key, value in newProps do
        if value == PropsUtil.NIL then
            result[key] = nil
        elseif key == Fusion.Children and typeof(value) == "table" and result[key] then
            for _, value2 in value do
                table.insert(result[key], value2)
            end
        else
            result[key] = value
        end
    end

    return result
end

-- Strips the specified props from the table.
function PropsUtil.StripProps(props, toStrip)
    local stripped = table.clone(props)

    for _, value in toStrip do
        stripped[value] = nil
    end

    return stripped
end

return PropsUtil