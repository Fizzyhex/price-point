local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value
local Spring = Fusion.Spring
local Hydrate = Fusion.Hydrate
local New = Fusion.New
local Children = Fusion.Children

local BillboardPrefab = ReplicatedStorage.Assets.UI.AfkBillboard

local function AfkBillboardManager()
    local binAdd, binEmpty = Bin()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local billboards = {}
    local billboardScales = {}

    local function GetBillboard(player: Player)
        if billboards[player] then
            return billboards[player]
        else
            local scale = Value(0)
            local billboard = BillboardPrefab:Clone()
            billboard.Name = `{player.Name}'s AFK billboard`
            billboard.Enabled = false
            billboard.ResetOnSpawn = false
            billboard.Parent = playerGui

            Hydrate(billboard:FindFirstChildWhichIsA("TextLabel")) {
                [Children] = New "UIScale" {
                    Scale = Spring(scale, 20)
                }
            }

            billboards[player] = billboard
            billboardScales[player] = scale

            return billboard
        end
    end

    binAdd(Observers.observePlayer(function(player: Player)
        local billboard = GetBillboard(player)

        return function()
            billboards[player] = nil
            billboardScales[player] = nil
            billboard:Destroy()
        end
    end))

    binAdd(Observers.observeCharacter(function(player: Player, character: Instance)
        local billboard = GetBillboard(player)
        billboard.Adornee = character
        billboard.Enabled = true

        local stopObservingAttribute = Observers.observeAttribute(player, "isAfk", function(value)
            billboardScales[player]:set(if value == true then 1 else 0)
        end)

        return function()
            stopObservingAttribute()
            billboard.Enabled = false
            billboard.Adornee = nil
        end
    end))

    return binEmpty
end

return AfkBillboardManager