local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

local AsyncInsertService = {}

function AsyncInsertService.LoadAsset(assetId: number)
    return Promise.new(function(resolve, reject)
        local ok, result = pcall(function()
            return InsertService:LoadAsset(assetId)
        end)

        if ok then
            resolve(result)
        else
            reject(result)
        end
    end)
end

return AsyncInsertService