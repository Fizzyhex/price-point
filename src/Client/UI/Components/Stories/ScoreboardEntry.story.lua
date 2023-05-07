local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local Value = Fusion.Value

local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local ScoreboardEntry = require(ReplicatedStorage.Client.UI.Components.ScoreboardEntry)

return function(target: Instance)
    local isReady = Value(false)
    local score = Value(5)
    local guess = Value(nil)

    local story = Nest {
        Parent = target,

        [Children] = {
            VerticalListLayout { Padding = UDim.new(0, 0) },
            ShorthandPadding { Padding = UDim.new(0, 8) },

            ScoreboardEntry {
                PlayerName = "OnlyTwentyCharacters",
                Avatar = "rbxthumb://type=AvatarHeadShot&id=40763226&w=352&h=352",
                IsReady = isReady,
                Score = score,
                Guess = guess,

                Size = UDim2.new(0, 700, 0, 50)
            },

            ScoreboardEntry {
                PlayerName = "Roblox",
                Avatar = "rbxthumb://type=AvatarHeadShot&id=1&w=352&h=352",
                IsReady = isReady,
                Score = score,
                Guess = guess,

                Size = UDim2.new(0, 700, 0, 50)
            }
        }
    }

    task.spawn(function()
        task.wait(1)
        isReady:set(true)
        task.wait(1)
        score:set(2359)
        task.wait(1)
        guess:set(100000)
    end)

    return function()
        story:Destroy()
    end
end