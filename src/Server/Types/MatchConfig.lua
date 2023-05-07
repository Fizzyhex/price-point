local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BasicStateContainer = require(ReplicatedStorage.Shared.BasicStateContainer)

export type MatchConfig = {
    rounds: number,
    timeToGuess: number,
    productPools: {},
    replicatedRoundState: typeof(BasicStateContainer.new()),
    scoreState: typeof(BasicStateContainer.new())
}

return nil