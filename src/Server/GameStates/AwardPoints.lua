local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local MatchConfig = require(ServerStorage.Server.Types.MatchConfig)

local logger = CreateLogger(script)

local function AwardPoints(system)
    return Promise.new(function(resolve)
        local finalGuesses = system:GetGuesses()
        local scoreStateContainer = system:GetScoreStateContainer()

        for playerId: number, guess: number in finalGuesses do
            local player = Players:GetPlayerByUserId(playerId)

            if not player then
                continue
            end

            scoreStateContainer:Patch({
                scoreStateContainer:Get("")
            })
        end

        resolve(system:GetStateByName("NextRound"))
    end)
end

return AwardPoints