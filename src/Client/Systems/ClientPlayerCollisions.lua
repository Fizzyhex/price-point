local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)
local ClientSettings = require(ReplicatedStorage.Client.State.ClientSettings)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)

local function ClientPlayerCollisions()
    local playerCollisionsEnabled = ClientSettings.PlayerCollisionsEnabled.value
    local network = Red.Client(NetworkNamespaces.COLLISIONS)

    local function Replicate()
        network:Fire("Toggle", playerCollisionsEnabled:get())
    end

    if not playerCollisionsEnabled:get() then
        Replicate()
    end

    return Fusion.Observer(playerCollisionsEnabled):onChange(Replicate)
end

return ClientPlayerCollisions