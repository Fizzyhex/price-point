local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Computed = Fusion.Computed
local Children = Fusion.Children
local New = Fusion.New
local Spring = Fusion.Spring

local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)

local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local HorizontalListLayout = require(ReplicatedStorage.Client.UI.Components.HorizontalListLayout)

local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)

local CORRECT_GUESS_COLOR = Color3.fromRGB(222, 133, 39)
local STRIPPED_PROPS = {
    "PlayerName",
    "Avatar",
    "Score",
    "Guess",
    "IsReady",
    "CorrectGuess"
}

local function Round(x)
    return math.floor(x + 0.5)
end

local function ScoreboardEntry(props)
    local isReady = props.IsReady
    local guess = props.Guess
    local score = props.Score
    local playerName = props.PlayerName
    local avatar = props.Avatar
    local correctGuess = props.CorrectGuess

    local defaultBackgroundColor = ThemeProvider:GetColor("background")
    local increasingBackgroundColor = ThemeProvider:GetColor("accent")

    local isTickVisible = Computed(function()
        return Unwrap(isReady) and Unwrap(guess) == nil
    end)

    local scoreSpring = Spring(Computed(function()
        local currentScore = Unwrap(score) or 0
        return currentScore
    end), 10)

    local animatedScoreRounded = Computed(function()
        return Round(scoreSpring:get())
    end)

    local backgroundColor = Spring(Computed(function()
        local currentScore = Unwrap(score) or 0
        local scoreSpringValue = scoreSpring:get()
        local percentage = 1 - (scoreSpringValue / currentScore)

        if scoreSpringValue < currentScore then
            return defaultBackgroundColor:get():Lerp(increasingBackgroundColor:get(), percentage)
        else
            return defaultBackgroundColor:get()
        end
    end), 20)

    local entry = Background {
        Name = "ScoreboardEntry",
        BackgroundColor3 = backgroundColor,

        [Children] = {
            ShorthandPadding { Padding = UDim.new(0, 6) },

            Nest {
                Name = "LeftNest",

                [Children] = {
                    HorizontalListLayout {
                        HorizontalAlignment = Enum.HorizontalAlignment.Left,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 6)
                    },

                    Label {
                        Name = "Score",

                        LayoutOrder = 1,
                        Text = animatedScoreRounded,
                        TextScaled = true,

                        AutomaticSize = Enum.AutomaticSize.None,

                        Size = UDim2.fromScale(2, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    },

                    New "ImageLabel" {
                        Name = "Avatar",
                        LayoutOrder = 2,
                        Image = avatar,
                        Size = UDim2.fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,

                        [Children] = New "UICorner" {
                            CornerRadius = UDim.new(1, 0)
                        }
                    },

                    Label {
                        Name = "Name",
                        LayoutOrder = 3,
                        Text = playerName,
                        TextScaled = true,
                        AutomaticSize = Enum.AutomaticSize.X,
                        Size = UDim2.fromScale(0, 0.8)
                    }
                }
            },

            Nest {
                Name = "RightNest",
                Size = UDim2.fromScale(3, 1),
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.fromScale(1, 0.5),
                SizeConstraint = Enum.SizeConstraint.RelativeYY,

                [Children] = {
                    HorizontalListLayout {
                        HorizontalAlignment = Enum.HorizontalAlignment.Center,
                        VerticalAlignment = Enum.VerticalAlignment.Center,
                        Padding = UDim.new(0, 6)
                    },

                    Label {
                        Name = "Guess",
                        LayoutOrder = 1,
                        TextColor3 = Spring(Computed(function()
                            local currentCorrectGuess = Unwrap(correctGuess)
                            return
                                if currentCorrectGuess and currentCorrectGuess == Unwrap(guess) then CORRECT_GUESS_COLOR
                                else Unwrap(ThemeProvider:GetColor("body"))
                        end), 20),
                        Text = Computed(function()
                            local currentGuess = Unwrap(guess)
                            return if currentGuess then currentGuess else ""
                        end),
                        FontFace = ThemeProvider:GetFontFace("bold"),
                        TextScaled = true,
                        AutomaticSize = Enum.AutomaticSize.None,
                        Size = Spring(Computed(function()
                            return if isTickVisible:get() then UDim2.fromScale(0, 0) else UDim2.fromScale(1, 1)
                        end), 20)
                    },

                    New "ImageLabel" {
                        Name = "Tick",
                        LayoutOrder = 2,
                        BackgroundTransparency = 1,
                        Image = "rbxassetid://6764432408",
                        ImageRectOffset = Vector2.new(200, 700),
                        ImageRectSize = Vector2.new(50, 50),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,

                        Size = Spring(Computed(function()
                            return if isTickVisible:get() then UDim2.fromScale(1, 1) else UDim2.fromScale(0, 0)
                        end), 20)
                    }
                }
            }
        }
    }

    return Hydrate(entry)(StripProps(props, STRIPPED_PROPS))
end

return ScoreboardEntry