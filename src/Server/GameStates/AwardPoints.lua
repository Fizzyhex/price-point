local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

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
        return a[2] > b[2]
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

        system:RevealGuesses()
        task.wait(2)

        OrderedScoreIterator(finalGuesses, function(playerId: number, guess: number)
            local player = Players:GetPlayerByUserId(playerId)

            if not player then
                return
            end

            local reward = 100 * PercentageDistance(guess, price)

            -- Prevent against NaN errors, as we have the potential to divide by zero here
            if reward ~= reward then
                reward = 0
            end

            if price == guess then
                reward = reward * 1.5
            end

            reward = Round(reward)

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

        task.wait(1)
        system:ResortScoreboards()
        logger.print("New scores:", scoreStateContainer:GetAll())
        task.wait(2)

        resolve(system:GetStateByName("NextRound"))
    end)
end

return AwardPoints