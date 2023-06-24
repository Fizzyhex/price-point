local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local DefaultData = require(ReplicatedStorage.Shared.Data.DefaultData)
local Promise = require(ReplicatedStorage.Packages.Promise)

local scope = if RunService:IsStudio() then "Studio" else "Production"
local dataStore = DataStoreService:GetDataStore("UserData", scope)
local logger = CreateLogger(script)
local dataCache = {}
local UserDataUtil = {}

local function GetUserKey(userId: number | string)
    return `user_{userId}`
end

function UserDataUtil.GetUserData(userId: number | string)
    local cached = dataCache[tostring(userId)]

    if cached then
        return Promise.resolve(TableUtil.Copy(cached))
    else
        return Promise.new(function(resolve, reject)
            local ok, data = pcall(function()
                return dataStore:GetAsync(GetUserKey(userId))
            end)

            if ok then
                if data then
                    data = TableUtil.Reconcile(data, DefaultData)
                else
                    data = TableUtil.Copy(DefaultData, true)
                end

                dataCache[tostring(userId)] = data
                return resolve(data)
            else
                logger.warn(`DATASTORE ERROR: Failed to get data for {userId}! {data}`)
                reject(data)
            end
        end)
    end

    -- Removes the user's data from the cache.
    return function()
        return UserDataUtil.RemoveFromCache(userId)
    end
end

function UserDataUtil.RemoveUserFromCache(userId: number | string)
    dataCache[tostring(userId)] = nil
end

function UserDataUtil.TransformUserData(userId: number | string, callback: (data: {}?) -> ())
    UserDataUtil.GetUserData(userId)
    :andThen(function(data)
        local newData = callback(TableUtil.Copy(data))

        if newData ~= nil then
            dataCache[tostring(userId)] = TableUtil.Copy(newData)
        end
    end, function()
        callback(nil)
    end)
end

function UserDataUtil.SaveUserData(userId: number | string)
    local data = dataCache[tostring(userId)]

    if data then
        data.placeId = game.PlaceId
        data.placeVersion = game.PlaceVersion

        return Promise.new(function(resolve, reject)
            local ok, result = pcall(function()
                -- Note: This is fine as we're not concerned about session-locking.
                -- Using SetAsync instead of UpdateAsync because UpdateAsync doesn't provide a way
                -- to associate UserIds with the key and I'm not trying to get assassinated by the EDPS.
                dataStore:SetAsync(GetUserKey(userId), data, {userId})
            end)

            if ok then
                resolve()
            else
                reject(result)
            end
        end)
    else
        return Promise.resolve()
    end
end

return UserDataUtil