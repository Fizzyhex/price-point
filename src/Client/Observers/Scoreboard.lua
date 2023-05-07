local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)
local Red = require(ReplicatedStorage.Packages.Red)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value

local ScoreStateContainer = require(ReplicatedStorage.Client.StateContainers.ScoreStateContainer)
local Blinder3D = require(ReplicatedStorage.Client.UI.Components.Blinder3D)
local ScoreboardEntry = require(ReplicatedStorage.Client.UI.Components.ScoreboardEntry)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)

local ANCESTORS = { workspace }

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
        local binAdd, binEmpty = Red.Bin()
        local entryPrefab = container:WaitForChild("Entry")
        entryPrefab.Parent = nil
        entryPrefab:WaitForChild("SurfaceGui")

        local isUninitialized = false
        local blinderDisplays: {typeof(Value())} = {}
        local blinders = {}
        local playerData = {}

        for i = 1, 10 do
            local entry = entryPrefab:Clone()
            entry.Name = i

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
            local unchangedDisplays = {}

            for _, value in blinderDisplays do
                unchangedDisplays[value] = true
            end

            OrderedScoreIterator(ScoreStateContainer:GetAll(), function(userId, score)
                local player = Players:GetPlayerByUserId(userId)

                if not player then
                    return
                end

                index += 1
                local blinderDisplay = blinderDisplays[index]

                if not blinderDisplay then
                    return
                end

                blinderDisplay:set(playerData[userId].ui)
                unchangedDisplays[blinderDisplay] = false
            end)

            -- Turn off any unused displays in case a player leaves the game
            for display, unchanged in unchangedDisplays do
                if unchanged then
                    display:set(nil)
                end
            end
        end

        binAdd(ScoreStateContainer:Observe(function(oldState, newState)
            if isUninitialized and next(newState) then
                ReorderScoreboard()
            end
        end))

        binAdd(OnServerScoreboardResort(ReorderScoreboard))

        binAdd(Observers.observePlayer(function(player)
            local playerBinAdd, playerBinEmpty = Red.Bin()
            local score = Value(0)

            playerBinAdd(ScoreStateContainer.FusionUtil.StateHook(
                ScoreStateContainer,
                score,
                player.UserId
            ))

            local ui = ScoreboardEntry {
                Name = `Entry (@{player.Name})`,
                PlayerName = player.Name,
                Score = score
            }
            playerBinAdd(ui)

            playerData[player.UserId] = {
                ui = ui,
                guess = Value(nil),
                isReady = Value(nil),
            }

            return function()
                playerBinEmpty()
                playerData[player.UserId] = nil
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