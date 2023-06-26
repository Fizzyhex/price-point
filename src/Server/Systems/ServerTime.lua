local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")

local ServerGameStateChannel = require(ServerStorage.Server.EventChannels.ServerGameStateChannel)

local INCREMENT_AMOUNT = 5.5

local function ServerTime()
    local isFirstGame = true

    ServerGameStateChannel.ObserveIntermissionBegun(function()
        if isFirstGame then
            isFirstGame = false
            return
        end

        Lighting:SetAttribute("ServerTime", (Lighting:GetAttribute("ServerTime") + INCREMENT_AMOUNT) % 24)
    end)
end

return ServerTime