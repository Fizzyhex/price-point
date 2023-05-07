local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value
local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local PriceGuessing = require(ReplicatedStorage.Client.UI.Components.Slides.PriceGuessing)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)

local fusionGameState = {
    productData = Value(),
    phase = Value(),
    guessingEnabled = Value()
}

local logger = CreateLogger(script)

for state, value in fusionGameState do
    RoundStateContainer.FusionUtil.StateHook(
        RoundStateContainer,
        value,
        state
    )
end

local GameMonitorPrimary = Component.new { Tag = "GameMonitorPrimary" }

function GameMonitorPrimary:Construct()
    self._trove = Trove.new()

    local currentSlide = Computed(function()
        local phase = fusionGameState.phase:get()
        logger.print("Phase:", phase)

        if phase == "PriceGuessing" then
            local productData = fusionGameState.productData:get() or {}

            return PriceGuessing {
                TextScaling = "cinema",
                ProductName = productData.name,
                ProductImage = productData.image,
            }
        end

        return nil
    end, Fusion.cleanup)

    local surfaceGui = New "SurfaceGui" {
        Name = "GameMonitorPrimary",
        PixelsPerStud = 6,
        ClipsDescendants = true,
        Parent = self.Instance,

        [Children] = {currentSlide}
    }

    self._trove:Add(surfaceGui)
end

function GameMonitorPrimary:Stop()
    self._trove:Destroy()
end

return GameMonitorPrimary