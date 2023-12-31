local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Red = require(ReplicatedStorage.Packages.Red)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)

local ANCESTORS = { workspace }

local function Podium()
    local stopObservingTag = Observers.observeTag("Podium", function(podium: Model)
        local binAdd, binEmpty = Bin()
        local podiumSpots = {}

        for _, child in podium:GetChildren() do
            local spotIndex = tonumber(child.Name)

            if spotIndex and child:IsA("BasePart") then
                podiumSpots[spotIndex] = child
            end
        end

        local function EnablePodiumSpot(spot: BasePart)
            spot:SetAttribute("Enabled", true)
            spot.Transparency = 0
            spot:FindFirstChildWhichIsA("SurfaceGui").Enabled = true
        end

        local function DisablePodiumSpot(spot: BasePart)
            spot:SetAttribute("Enabled", false)
            spot.Transparency = 1
            spot:FindFirstChildWhichIsA("SurfaceGui").Enabled = false
        end

        local function UpdatePodiumSpots()
            local playerCount = 1--#Players:GetPlayers()

            if playerCount >= 5 then
                for _, spot in podiumSpots do
                    EnablePodiumSpot(spot)
                end
            else
                EnablePodiumSpot(podiumSpots[1])
                -- Hide all podium spots apart from #1 for low player counts
                for index, spot in podiumSpots do
                    if index == 1 then
                        continue
                    end

                    DisablePodiumSpot(spot)
                end
            end
        end

        UpdatePodiumSpots()
        binAdd(Players.PlayerAdded:Connect(UpdatePodiumSpots))
        binAdd(Players.PlayerRemoving:Connect(UpdatePodiumSpots))
        return binEmpty
    end, ANCESTORS)

    return stopObservingTag
end

return Podium