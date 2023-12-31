local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local MusicController = require(ServerStorage.Server.MusicController)
local Promise = require(ReplicatedStorage.Packages.Promise)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local NumberUtil = require(ReplicatedStorage.Shared.Util.NumberUtil)
local PlayRandomSound = require(ReplicatedStorage.Shared.Util.PlayRandomSound)

local REWARD_SCORE_SOUND_TAG = "RewardScoreSound"

local logger = CreateLogger(script)

local function PercentageDistance(a, b)
    local distance = 1 - (math.abs(a - b) / math.max(a, b))
    return if distance == distance then distance else 1
end

local function Round(x)
    return math.floor(x + 0.5)
end

local function OrderScoresDescending(scores)
    local sorted = {}

    for userId, score in scores do
        table.insert(sorted, {userId, score})
    end

    table.sort(sorted, function(a, b)
        return a[2] > b[2]
    end)

    return sorted
end

local function PlaySoundsWithTag(tag: string, playbackSpeed: number?)
    for _, sound: Sound in CollectionService:GetTagged(tag) do
        if sound:IsA("Sound") then
            if playbackSpeed then
                sound.PlaybackSpeed = playbackSpeed
            end

            sound:Play()
        end
    end
end

local function scoreGuess(price, guess)
    -- Adding 50 prevents against us from awarding 0 points when the price is 0
    return 100 * PercentageDistance(guess + 50, price + 50)
end

local function RewardPoints(system)
    return Promise.new(function(resolve)
        local finalGuesses = system:GetGuesses()
        local scoreStateContainer = system:GetScoreStateContainer()
        local replicatedRoundState = system:GetRoundStateContainer()
        local price = system:GetCurrentProductPrice()
        local waitTime = 0.5
        local playbackSpeed = 1
        logger.print("Old scores:", scoreStateContainer:GetAll())

        system:RevealGuesses()
        system:ResortScoreboards()
        
        MusicController.SetCategory("Intermission")

        local topGuesser

        for userId, guess in finalGuesses do
            local score = scoreGuess(price, guess)

            if topGuesser == nil or scoreGuess(price, finalGuesses[topGuesser]) < score then
                topGuesser = userId
            end
        end

        if topGuesser then
            local player = Players:GetPlayerByUserId(topGuesser)

            if player then
                local guess = finalGuesses[topGuesser]
                local distance = PercentageDistance(price, guess)
                local headerText
                local titleBackgroundColor = "background"

                if price == guess then
                    titleBackgroundColor = "background_gold"
                    headerText = `{player.DisplayName} guessed exactly!`
                    ReplicatedStorage.Assets.Sounds.ExactGuess:Play()
                elseif distance > 0.75 then
                    titleBackgroundColor = "background_gold"
                    ReplicatedStorage.Assets.Sounds.CloseGuess:Play()
                    headerText = `{player.DisplayName} was close:`
                else
                    if distance < 0.3 then
                        PlayRandomSound(ReplicatedStorage.Assets.Sounds.NotClose:GetChildren())
                    end

                    headerText = `{player.DisplayName} guessed:`
                end

                replicatedRoundState:Patch({
                    headerText = headerText,
                    bodyText = `\u{E002}{NumberUtil.CommaSeperate(guess)}`,
                    titleBackgroundColor = titleBackgroundColor
                })
            end
        end
        
        task.wait(2)

        local function GiveOutRewards()
            local oldScores = scoreStateContainer:GetAll()

            -- Add any new guessers onto the scoreboard
            for userId in finalGuesses do
                if not oldScores[userId] then
                    oldScores[userId] = 0
                end
            end

            for _, value in OrderScoresDescending(oldScores) do
                local userId = value[1]
                local score = value[2]
                local guess = finalGuesses[userId]

                if not guess then
                    continue
                end

                local player = Players:GetPlayerByUserId(userId)

                if not player then
                    continue
                end

                local reward = scoreGuess(price, guess)

                -- Prevent against NaN errors, as we have the potential to divide by zero here
                if reward ~= reward then
                    reward = 0
                end

                if price == guess then
                    reward = reward * 1.5
                end

                reward = Round(reward)

                if reward ~= 0 then
                    local newScore = score + reward
                    scoreStateContainer:Patch({
                        [userId] = newScore
                    })

                    logger.print(`Rewarded {player} with {reward}, new score is {newScore}`)
                    PlaySoundsWithTag(REWARD_SCORE_SOUND_TAG, playbackSpeed)
                    task.wait(waitTime)
                    playbackSpeed = math.min(playbackSpeed + 0.05, 1.3)
                    waitTime = math.max(waitTime - 0.05, 0.2)
                end
            end
        end

        GiveOutRewards()
        system:ResortScoreboards()
        logger.print("New scores:", scoreStateContainer:GetAll())
        task.wait(2)

        replicatedRoundState:Patch({
            headerText = replicatedRoundState.NONE,
            bodyText = replicatedRoundState.NONE,
            titleBackgroundColor = replicatedRoundState.NONE
        })

        resolve(system:GetStateByName("NextRound"))
    end)
end

return RewardPoints