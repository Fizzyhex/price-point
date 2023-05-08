local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)

local Red = require(ReplicatedStorage.Packages.Red)

local function PlayerGuessRecorder(onGuessCallback: (player: Player, guess: number) -> ())
    local network = Red.Server(NetworkNamespaces.GUESS_SUBMISSION, {"Submit"})
    local guesses = {}

    network:On("Submit", function(player: Player, guess: number)
        if guess ~= guess then
            return
        end

        if typeof(guess) ~= "number" then
            return
        end

        guesses[player.UserId] = guess

        if onGuessCallback then
            onGuessCallback(player, guess)
        end
    end)

    -- Stops recording guesses and outputs a dict of UserIds corresponding with guesses
    return function()
        network:On("Submit", nil)
        return guesses
    end
end

return PlayerGuessRecorder