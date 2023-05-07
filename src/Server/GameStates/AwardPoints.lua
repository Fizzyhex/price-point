local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local MatchConfig = require(ServerStorage.Server.Types.MatchConfig)

local logger = CreateLogger(script)

local function PercentageDistance(a, b)
    return 1 - (math.abs(a - b) / math.max(a, b))
end

local function Round(x)
    return math.floor(x + 0.5)
end

local function OrderedScoreIterator(scores: table, iteratorFn: (key: any, value: any) -> ())
    local orderedScores = {}

    for scorer, score in scores do
        table.insert(orderedScores, {scorer, score})
    end

    table.sort(orderedScores, function(a, b)
        return a[1] > b[1]
    end)

    for _, value in orderedScores do
        iteratorFn(value[1], value[2])
    end
end

local function AwardPoints(system)
    return Promise.new(function(resolve)
        local finalGuesses = system:GetGuesses()
        local scoreStateContainer = system:GetScoreStateContainer()
        local price = system:GetCurrentProduct().PriceInRobux
        local waitTime = 0.5

        logger.print("Old scores:", scoreStateContainer:GetAll())

        OrderedScoreIterator(finalGuesses, function(playerId: number, guess: number)
            local player = Players:GetPlayerByUserId(playerId)

            if not player then
                return
            end

            local reward = 100 / PercentageDistance(guess, price)

            if price == guess then
                reward = Round(reward * 1.5)
            end

            if reward ~= 0 then
                local currentScore = scoreStateContainer:Get(playerId, 0)
                local newScore = currentScore + reward
                scoreStateContainer:Patch({
                    [playerId] = newScore
                })

                logger.print(`Rewarded {player} with {reward}, new score is {newScore}`)

                task.wait(waitTime)
                waitTime = math.max(waitTime - 0.05, 0.2)
            end
        end)

        system:ResortScoreboards()
        logger.print("New scores:", scoreStateContainer:GetAll())

        resolve(system:GetStateByName("NextRound"))
    end)
end

return AwardPoints