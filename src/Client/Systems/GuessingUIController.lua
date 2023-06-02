local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Red = require(ReplicatedStorage.Packages.Red)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value
local New = Fusion.New
local Children = Fusion.Children
local Out = Fusion.Out
local Spring = Fusion.Spring
local Computed = Fusion.Computed

local TextBox = require(ReplicatedStorage.Client.UI.Components.TextBox)
local PrimaryButton = require(ReplicatedStorage.Client.UI.Components.PrimaryButton)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local HorizontalListLayout = require(ReplicatedStorage.Client.UI.Components.HorizontalListLayout)

local TextFilters = require(ReplicatedStorage.Client.UI.Util.TextFilters)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)

local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)

local LOCAL_PLAYER = Players.LocalPlayer
local gameRules = ReplicatedStorage.Assets.Configuration.GameRules

local function GuessingUIController()
    local guessNetwork = Red.Client(NetworkNamespaces.GUESS_SUBMISSION)
    local playerGui = LOCAL_PLAYER:WaitForChild("PlayerGui")
    local isGuessingAvailable = Value(false)
    local currentGuess = Value("")
    local currentGuessingUi = Value(nil)
    local uiPosition = Spring(Computed(function()
        return
            if isGuessingAvailable:get() then UDim2.fromScale(0.5, 0.9)
            else UDim2.new(0.5, 0, 2, 0)
    end), 10)

    local function ValidateGuess(guess: number)
        if
            guess == nil
            or guess ~= guess
            or guess < 0
            or math.ceil(guess) ~= guess
        then
            return false
        end

        return true
    end

    local function SubmitGuess()
        if not isGuessingAvailable:get() then
            return
        end

        local guess = tonumber(currentGuess:get())
        print("Guess:", guess)

        if ValidateGuess(guess) then
            print("Submitted guess", guess)
            guessNetwork:Call("Submit", guess)
            isGuessingAvailable:set(false)
        end
    end

    RoundStateContainer:Observe(function(oldState, newState)
        if oldState.guessingEnabled == newState.guessingEnabled then
            return
        end

        isGuessingAvailable:set(newState.guessingEnabled == true)

        if newState.guessingEnabled then
            currentGuessingUi:set(Nest {
                Size = UDim2.fromScale(0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                Position = uiPosition,
                AnchorPoint = Vector2.new(0.5, 1),

                [Children] = {
                    TextBox {
                        Name = "GuessBox",
                        LayoutOrder = 1,
                        PlaceholderText = "How much Robux do you think this costs?",
                        TextFilters = {
                            TextFilters.Min(gameRules:GetAttribute("minGuess")),
                            TextFilters.Max(gameRules:GetAttribute("maxGuess")),
                            TextFilters.WholeNumber()
                        },

                        OnFocusLost = function(enterPressed)
                            if enterPressed then
                                SubmitGuess()
                            end
                        end,

                        [Out "Text"] = currentGuess
                    },

                    PrimaryButton {
                        Text = "Submit!",
                        LayoutOrder = 2,
                        Name = "SubmitButton",
                        OnClick = SubmitGuess
                    },

                    HorizontalListLayout { Padding = UDim.new(0, 12) },
                },
            })
        end
    end)

    New "ScreenGui" {
        Parent = playerGui,
        Name = "GuessingUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,

        [Children] = {
            currentGuessingUi,
        }
    }
end

return GuessingUIController