local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local ServerGameStateChannel = require(ServerStorage.Server.EventChannels.ServerGameStateChannel)
local MusicController = require(ServerStorage.Server.MusicController)

local logger = CreateLogger(script)

local function ToTitlecase(str: string)
    return str:sub(1, 1):upper() .. str:sub(2)
end

local function Intermission(system)
    return Promise.new(function(resolve)
        local roundStateContainer = system:GetRoundStateContainer()
        local scoreStateContainer = system:GetScoreStateContainer()
        local intermissionLength = system:GetIntermissionTime()
        roundStateContainer:Clear()
        system:ClearMatchStateContainer()

        MusicController.SetCategory("Intermission")

        if RunService:IsStudio() then
            intermissionLength = 3
        end

        while true do
            if #system:GetActivePlayers() == 0 then
                Players.PlayerAdded:Wait()
            else
                break
            end
        end

        ServerGameStateChannel.RaiseIntermissionBegun()

        roundStateContainer:Patch({
            phase = "Intermission",
            roundTimer = workspace:GetServerTimeNow(),
            roundDuration = intermissionLength,
        })

        logger.print(`Intermission {intermissionLength}...`)
        task.wait(intermissionLength)

        local scorePatch = scoreStateContainer:GetAll()

        -- Reset all scores, insuring to remove players from the scoreboard if they have left.
        for userId in scorePatch do
            if not Players:GetPlayerByUserId(userId) then
                scorePatch[userId] = scoreStateContainer.NONE
            else
                scorePatch[userId] = 0
            end
        end

        for _, player in Players:GetPlayers() do
            scorePatch[player.UserId] = 0
        end

        scoreStateContainer:Patch(scorePatch)
        local matchCategories = system:PickMatchCategories()
        local matchCategoriesTitlecase = {}

        for index, category in matchCategories do
            matchCategoriesTitlecase[index] = ToTitlecase(category)
        end

        system:SetModeName(table.concat(matchCategoriesTitlecase, " & "))
        resolve(system:GetStateByName("NextRound"))
    end)
end

return Intermission