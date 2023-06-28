local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value

local SettingsPannel = require(ReplicatedStorage.Client.UI.Components.SettingsPannel)
local ClientSettings = require(ReplicatedStorage.Client.State.ClientSettings)
local TopbarIcon = require(ReplicatedStorage.TopbarIcon)
local TopbarThemes = require(ReplicatedStorage.Client.UI.TopbarThemes)

local function RenderSettingsPannel()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local isOpen = Value(false)
    local sounds = {
        open = New "Sound" {
            Name = "Open",
            SoundId = "rbxassetid://6042053626"
        },

        close = New "Sound" {
            Name = "Open",
            SoundId = "rbxassetid://6042053626",
            PlaybackSpeed = 0.9
        }
    }

    TopbarIcon.new()
        :setName("Settings")
        :setImage("rbxassetid://13829996168")
        :setLabel("Settings")
        :setTheme(TopbarThemes.PricePoint)
        :bindEvent("selected", function(self)
            isOpen:set(true)
            sounds.open:Play()
        end)
        :bindEvent("deselected", function(self)
            isOpen:set(false)
            sounds.close:Play()
        end)

    local pannel = New "ScreenGui" {
        Name = "Settings",
        Parent = playerGui,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Enabled = isOpen,

        [Children] = {
            SettingsPannel {
                Position = UDim2.fromScale(0.5, 0.5),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Settings = ClientSettings
            },

            sounds
        }
    }

    return function()
        pannel:Destroy()
    end
end

return RenderSettingsPannel