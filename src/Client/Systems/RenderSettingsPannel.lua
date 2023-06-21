local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children

local SettingsPannel = require(ReplicatedStorage.Client.UI.Components.SettingsPannel)
local ClientSettings = require(ReplicatedStorage.Client.State.ClientSettings)

local function RenderSettingsPannel()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    local pannel = New "ScreenGui" {
        Name = "Settings",
        Parent = playerGui,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,

        [Children] = {
            SettingsPannel {
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Settings = ClientSettings
            }
        }
    }

    return function()
        pannel:Destroy()
    end
end

return RenderSettingsPannel