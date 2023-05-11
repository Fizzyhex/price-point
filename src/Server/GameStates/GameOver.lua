local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Promise = require(ReplicatedStorage.Packages.Promise)

local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local ServerItemProjector = require(ServerStorage.Server.Components.ServerItemProjector)

local logger = CreateLogger(script)

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

local function TeleportOntoPodium(characters, podiumSpots)
    local oldPivots = {}
    local podiumCharacters = {}

    -- Teleport players onto the podium
    for _, character in characters do
        local _, spot = next(podiumSpots)

        if not spot then
            break
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")

        -- if rootPart and rootPart:CanSetNetworkOwnership() then
        --     rootPart:SetNetworkOwner(nil)
        -- end

        table.insert(oldPivots, character:GetPivot())
        rootPart:PivotTo(spot)
        table.insert(podiumCharacters, character)
    end

    return function()
        for index, character in podiumCharacters do
            pcall(function()
                character:PivotTo(oldPivots[index])
            end)
        end
    end
end

local function GameOver(system)
    return Promise.new(function(resolve)
        logger.print("Game over - restarting in 5s")
        local podium = CollectionService:GetTagged("Podium")[1]
        podium:SetAttribute("isVisible", true)
        local podiumCharacters: {Model} = {}
        local podiumCharacterOldPivots = {}
        local podiumSpots = {}
        local scoreStateContainer = system:GetScoreStateContainer()
        local roundStateContainer = system:GetRoundStateContainer()
        local scores = scoreStateContainer:GetAll()
        local orderedScores = {}
        local podiumOrientation = podium:FindFirstChild("Orientation").CFrame.Rotation

        for userId, score in scores do
            table.insert(orderedScores, {userId, score})
        end

        table.sort(orderedScores, function(a, b)
            return a[2] > b[2]
        end)

        for _, component in ServerItemProjector:GetAll() do
            component:SetModel(nil)
        end

        local winnerUserId, _ = next(orderedScores)

        if winnerUserId then
            local winner = Players:GetPlayerByUserId(winnerUserId)
            print("Got winner", winner)

            if winner then
                print("Doing winner patch")
                roundStateContainer:Patch({
                    phase = "GameOver",
                    winnerName = winner.DisplayName
                })
            end
        end

        -- Determine spots on the podium and display scores
        for _, part: BasePart in podium:GetChildren() do
            if not part:IsA("BasePart") then
                continue
            end

            local placement = tonumber(part.Name)

            if not placement then
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

        -- Teleport players onto the podium
        for _, data in orderedScores do
            local userId = data[1]
            local score = data[2]
            local spotIndex, spot = next(podiumSpots)

            if #podiumSpots == 0 then
                break
            end

            if score <= 0 then
                continue
            end

            local player = Players:GetPlayerByUserId(userId)

            if not player then
                continue
            end

            podiumSpots[spotIndex] = nil
            local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

            -- if rootPart and rootPart:CanSetNetworkOwnership() then
            --     rootPart:SetNetworkOwner(nil)
            -- end

            table.insert(podiumCharacterOldPivots, player.Character:GetPivot())
            rootPart:PivotTo(spot)
            table.insert(podiumCharacters, player.Character)
        end

        task.wait(system:GetConclusionTime())

        -- Teleport players back to where they were standing before
        for index, character in podiumCharacters do
            if not character:IsDescendantOf(game) then
                continue
            end

            local rootPart: BasePart = character:FindFirstChild("HumanoidRootPart")
            print("Teleporting", character, "back to", podiumCharacterOldPivots[index])
            character:PivotTo(podiumCharacterOldPivots[index])

            if rootPart and rootPart:CanSetNetworkOwnership() then
                task.defer(function()
                    rootPart:SetNetworkOwnershipAuto()
                end)
            end
        end

        podium:SetAttribute("isVisible", false)
        resolve(false)
    end)
end

return GameOver