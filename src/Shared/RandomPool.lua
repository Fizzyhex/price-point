local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local RANDOM_GEN = Random.new()

-- An array that automatically shuffles and regenerates
local RandomPool = {}
RandomPool.__index = RandomPool

function RandomPool.new(templateData, random: Random?)
    local self = setmetatable({}, RandomPool)
    self._template = templateData
    self._pool = {}
    self._random = random or RANDOM_GEN
    return self
end

function RandomPool:Pop()
    if #self._pool == 0 then
        for key, value in TableUtil.Shuffle(self._template, self._random) do
            self._pool[key] = value
        end
    end

    return table.remove(self._pool, #self._pool)
end

function RandomPool:IsEmpty()
    return #self._pool == 0
end

return RandomPool