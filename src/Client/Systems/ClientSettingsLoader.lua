local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local ClientSettings = require(ReplicatedStorage.Client.State.ClientSettings)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local logger = CreateLogger(script)

local function ClientSettingsLoader()
    local userDataNetwork = Red.Client(NetworkNamespaces.USER_DATA)
    local savePayload = {}
    local saveThread: thread?

    local function LoadClientSettings()
        local data = userDataNetwork:Call("RequestSettings"):Await()
        logger.print("Received settings from server", data)

        if not data then
            return
        end

        for id, value in data do
            if not ClientSettings[id] then
                continue
            end

            ClientSettings[id].value:set(value)
        end

        logger.print("Reconciled client settings!", data)
    end

    local function SendSaveToServer()
        if next(savePayload) == nil then
            return
        end

        userDataNetwork:Fire("SaveSettings", TableUtil.Copy(savePayload))
        logger.print("Sent save to server", savePayload)
        table.clear(savePayload)
    end

    local function TickSaveClock()
        if saveThread then
            task.cancel(saveThread)
        end

        saveThread = task.spawn(function()
            -- In theory the player could leave 0.5 seconds before changing their settings
            -- and it wouldn't save. BindToClose doesn't work on the client, soo ¯\_(ツ)_/¯
            task.wait(0.25)
            SendSaveToServer()
        end)
    end

    local function ObserveSettings()
        for _, setting in ClientSettings do
            Fusion.Observer(setting.value):onChange(function()
                savePayload[setting.id] = setting.value:get()
                TickSaveClock()
            end)
        end
    end

    LoadClientSettings()
    ObserveSettings()
end

return ClientSettingsLoader