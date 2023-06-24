local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VoiceChatService = game:GetService("VoiceChatService")

local IconController = require(ReplicatedStorage.TopbarIcon.IconController)
local TopbarThemes = require(ReplicatedStorage.Client.UI.TopbarThemes)

local function ConfigureTopbarPlus()
    IconController.setGameTheme(TopbarThemes.PricePoint)

    task.spawn(function()
        IconController.voiceChatEnabled = VoiceChatService:IsVoiceEnabledForUserIdAsync(Players.LocalPlayer.UserId)
    end)
end

return ConfigureTopbarPlus