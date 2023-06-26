local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)

local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local ServerItemProjector = require(ServerStorage.Server.Components.ServerItemProjector)
local CharacterChannel = require(ServerStorage.Server.EventChannels.CharacterChannel)

local logger = CreateLogger(script)

local function OrderedScoresIterator(t: table)
    local index = 0

    return function()
        index += 1
        local value = t[index]

        if value then
            return unpack(value)
        else
            return nil, nil
        end
    end
end

local function SetupPodium(orderedScores, podium)
    local podiumSpots = {}
    local podiumOrientation = podium:FindFirstChild("Orientation").CFrame.Rotation

    -- Determine spots on the podium and display scores
    for _, part: BasePart in podium:GetChildren() do
        if not part:IsA("BasePart") then
            continue
        end

        local placement = tonumber(part.Name)

        if not placement then
            continue
        end

        if part:GetAttribute("Enabled") == false then
            continue
        end

        local score = orderedScores[placement] and orderedScores[placement][2]
        local statsFrame = part.SurfaceGui.Stats

        if score then
            statsFrame.Visible = true
            statsFrame.Score.Text = `{score} POINTS`
        else
            statsFrame.Visible = false
        end

        podiumSpots[placement] = podiumOrientation + part.Position + Vector3.new(0, part.Size.Y / 2, 0)
    end

    return podiumSpots
end

local function TeleportOntoPodium(characters: {Instance}, podiumSpots)
    local oldPivots = {}
    local podiumCharacters = {}
    podiumSpots = table.clone(podiumSpots)

    -- Teleport players onto the podium
    for _, character in characters do
        local spot = table.remove(podiumSpots, 1)

        if spot == nil then
            break
        end

        table.insert(oldPivots, character:GetPivot())
        table.insert(podiumCharacters, character)
        CharacterChannel.RaiseTeleportBegun(character, spot)
    end

    return function()
        for index, character in podiumCharacters do
            pcall(function()
                CharacterChannel.RaiseTeleportBegun(character, oldPivots[index])
            end)
        end
    end
end

local function SortScores(scores)
    local orderedScores = {}

    for userId, score in scores do
        table.insert(orderedScores, {userId, score})
    end

    table.sort(orderedScores, function(a, b)
        return a[2] > b[2]
    end)

    return orderedScores
end

local function GameOver(system)
    return Promise.new(function(resolve)
        logger.print("Game over - restarting in 5s")
        local podium = CollectionService:GetTagged("Podium")[1]
        local scoreStateContainer = system:GetScoreStateContainer()
        local roundStateContainer = system:GetRoundStateContainer()
        local orderedScores = SortScores(scoreStateContainer:GetAll())
        local orderedCharacters = {}
        local winner

        podium:SetAttribute("isVisible", true)

        for _, component in ServerItemProjector:GetAll() do
            component:SetModel(nil)
        end

        for userId, score in OrderedScoresIterator(orderedScores) do
            -- Players with 0 score should not be put on the podium
            if score == 0 then
                continue
            end

            local player = Players:GetPlayerByUserId(userId)

            if player then
                if not winner then
                    winner = player
                end

                table.insert(orderedCharacters, player.Character)
            end
        end

        if winner then
            roundStateContainer:Patch({
                phase = "GameOver",
                winnerName = winner.DisplayName
            })
        end

        local podiumSpots = SetupPodium(orderedScores, podium)
        local revertPodiumTeleports = TeleportOntoPodium(orderedCharacters, podiumSpots)
        ReplicatedStorage.Assets.Sounds.Win:Play()
        task.wait(system:GetConclusionTime())
        revertPodiumTeleports()
        podium:SetAttribute("isVisible", false)
        resolve(false)
    end)
end

return GameOver