local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local logger = CreateLogger(script)

local function Intermission(system)
    return Promise.new(function(resolve)
        local roundStateContainer = system:GetRoundStateContainer()
        local scoreStateContainer = system:GetScoreStateContainer()
        local intermissionLength = system:GetIntermissionTime()
        roundStateContainer:Clear()

        while true do
            if #system:GetActivePlayers() == 0 then
                Players.PlayerAdded:Wait()
            else
                break
            end
        end

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
        resolve(system:GetStateByName("NextRound"))
    end)
end

return Intermission