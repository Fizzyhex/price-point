local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Red = require(ReplicatedStorage.Packages.Red)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value

local StateContainers = require(ReplicatedStorage.Shared.StateContainers)
local scoreStateContainer = StateContainers.scoreStateContainer
local guessStateContainer = StateContainers.guessStateContainer
local Blinder3D = require(ReplicatedStorage.Client.UI.Components.Blinder3D)
local ScoreboardEntry = require(ReplicatedStorage.Client.UI.Components.ScoreboardEntry)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local roundStateContainer = StateContainers.roundStateContainer
local ScoreboardChannel = require(ReplicatedStorage.Client.EventChannels.ScoreboardChannel)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)

local ANCESTORS = { workspace }

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

local function Scoreboard()
    local scoreboardNetwork = Red.Client(NetworkNamespaces.SCOREBOARD)
    local scoreboardResortListeners = {}

    local function OnServerScoreboardResort(callback)
        scoreboardResortListeners[callback] = callback

        return function()
            scoreboardResortListeners[callback] = nil
        end
    end

    scoreboardNetwork:On("Resort", function()
        for _, callback in scoreboardResortListeners do
            callback()
        end
    end)

    return Observers.observeTag("Scoreboard", function(container: Model)
        local binAdd, binEmpty = Bin()
        local entryPrefab = container:WaitForChild("Entry")
        entryPrefab.Parent = nil
        entryPrefab:WaitForChild("SurfaceGui")

        local isUninitialized = false
        local blinderDisplays: {typeof(Value())} = {}
        local blinders = {}
        local playerDataTable = {}
        local price = Value()
        binAdd(roundStateContainer.FusionUtil.StateHook(roundStateContainer, price, "price"))

        for i = 1, 10 do
            local entry = entryPrefab:Clone()
            entry.Name = `ScoreboardEntryPart ({i})`
            local entryOffset = i - 1
            entry.CFrame *= CFrame.new(0, -entry.Size.Y * entryOffset, 0)

            local display = Value(nil)
            local blinder = Blinder3D {
                Part = entry,
                SurfaceGui = entry.SurfaceGui,
                Display = display
            }

            table.insert(blinders, blinder)
            table.insert(blinderDisplays, display)
            entry.Parent = container
        end

        local function ReorderScoreboard()
            local index = 0
            local scores = scoreStateContainer:GetAll()
            local lenBlinderDisplays = #TableUtil.Values(blinderDisplays)
            local isReordered = false
            print("Client scoreboard sees these scores:", scores)

            OrderedScoreIterator(scores, function(userId, score)
                local player = Players:GetPlayerByUserId(userId)

                if not player then
                    return
                end

                local data = playerDataTable[tostring(userId)]

                if not data then
                    return
                end

                index += 1
                local blinderDisplay = blinderDisplays[index]

                if not blinderDisplay then
                    return
                end

                if blinderDisplay:get() ~= data.ui then
                    isReordered = true
                    blinderDisplay:set(data.ui)
                end
            end)

            if #scores > lenBlinderDisplays then
                -- Turn off any unused displays
                for i = #scores + 1, lenBlinderDisplays do
                    blinderDisplays[i]:set(nil)
                end
            end

            if isReordered then
                ScoreboardChannel.RaiseScoreboardResort(container)
            end
        end

        binAdd(Observers.observePlayer(function(player)
            local playerBinAdd, playerBinEmpty = Bin()
            local score = Value(0)
            local key = tostring(player.UserId)
            local guess = Value(nil)
            local isReady = Value(nil)

            playerBinAdd(scoreStateContainer.FusionUtil.StateHook(
                scoreStateContainer,
                score,
                key
            ))

            local ui = ScoreboardEntry {
                Name = `ScoreboardEntry (@{player.Name})`,
                PlayerName = player.Name,
                Score = score,
                Avatar = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=352&h=352`,
                Guess = guess,
                CorrectGuess = price,
                IsReady = isReady
            }
            playerBinAdd(ui)

            playerDataTable[key] = {
                ui = ui,
                guess = guess,
                isReady = isReady,
            }

            return function()
                playerBinEmpty()
                playerDataTable[key] = nil
            end
        end))

        binAdd(scoreStateContainer:Observe(function(_, newState)
            if isUninitialized and next(newState) then
                ReorderScoreboard()
            end
        end))

        binAdd(OnServerScoreboardResort(ReorderScoreboard))

        binAdd(guessStateContainer:Observe(function(oldState, newState)
            for userId, guess in newState do
                if oldState[userId] == guess then
                    continue
                end

                local data = playerDataTable[userId]

                if not data then
                    continue
                end

                if typeof(guess) == "boolean" then
                    data.isReady:set(guess)
                    data.guess:set(nil)
                elseif guess ~= nil then
                    data.guess:set(guess)
                end
            end

            for userId in oldState do
                local data = playerDataTable[userId]

                if not data then
                    continue
                end

                if newState[userId] == nil then
                    data.guess:set(nil)
                    data.isReady:set(false)
                end
            end
        end))

        return function()
            binEmpty()
            pcall(function()
                entryPrefab.Parent = container
            end)
        end
    end, ANCESTORS)
end

return Scoreboard