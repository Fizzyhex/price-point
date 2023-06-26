local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local UserDataUtil = require(ServerStorage.Server.Util.UserDataUtil)
local CreateDefaultSettings = require(ReplicatedStorage.Shared.Data.CreateDefaultSettings)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)

local SAVE_INTERVAL = 120

local logger = CreateLogger(script)
local defaultSettings = CreateDefaultSettings()

local function ValidateSettings(unsure: {})
    local valid = {}

    for _, settingData in defaultSettings do
        local userValue = unsure[settingData.id]

        if userValue == nil then
            continue
        end

        local defaultValue = settingData.value:get()

        if typeof(defaultValue) ~= typeof(userValue) then
            continue
        end

        -- important to check for NaN!
        if userValue ~= userValue then
            continue
        end

        if settingData.min and userValue < settingData.min then
            continue
        end

        if settingData.max and userValue > settingData.max then
            continue
        end

        if settingData.options then
            local isValid = false

            for id in settingData.options do
                if id == userValue then
                    isValid = true
                    break
                end
            end

            if not isValid then
                continue
            end
        end

        -- Don't bother saving default settings
        if userValue == defaultValue then
            continue
        end

        valid[settingData.id] = userValue
    end

    return valid
end

local function UserDataManager()
    local binAdd, binEmpty = Bin()
    local userDataNetwork = Red.Server(NetworkNamespaces.USER_DATA)
    local settingsRequestDebounce = {}

    userDataNetwork:On("SaveSettings", function(player: Player, remoteData)
        if not typeof(remoteData) == "table" then
            return
        end

        local save = ValidateSettings(remoteData)
        logger.print("Constructed user save", save, "from", remoteData)

        UserDataUtil.TransformUserData(player.UserId, function(userData)
            if not userData then
                return
            end

            userData.settings = TableUtil.Reconcile(remoteData, userData.settings)
            return userData
        end)
    end)

    local function SaveAllUserData()
        for _, player in Players:GetPlayers() do
            if not player:IsDescendantOf(Players) then
                continue
            end

            local worked, result = UserDataUtil.SaveUserData(player.UserId):await()

            if not worked then
                logger.warn(`Failed to save {player} ({player.UserId})'s data: {result}`)
            end
        end
    end

    -- Note: This is not hot reloadable!
    game:BindToClose(function()
        logger.print("Saving all user data before close...")
        SaveAllUserData()
    end)

    local saveThread = task.spawn(function()
        while true do
            task.wait(SAVE_INTERVAL)
            SaveAllUserData()
        end
    end)

    binAdd(function()
        task.cancel(saveThread)
    end)

    userDataNetwork:On("RequestSettings", function(player: Player)
        if settingsRequestDebounce[player] then
            return nil
        end

        local worked, userData = UserDataUtil.GetUserData(player.UserId)
            :catch(function(err)
                logger.warn(`Failed to load data for {player} ({player.UserId}):`, tostring(err))
            end)
            :await()

        settingsRequestDebounce[player] = true
        return if worked then userData.settings else nil
    end)

    binAdd(Observers.observePlayer(function(player)
        return function()
            settingsRequestDebounce[player] = nil
            UserDataUtil.SaveUserData(player.UserId)
                :finally(function()
                    -- Make sure they left the server before we uncache
                    if not Players:GetPlayerByUserId(player.UserId) then
                        UserDataUtil.RemoveUserFromCache(player.UserId)
                    end
                end)
                :catch(warn)
        end
    end))

    return binEmpty
end

return UserDataManager