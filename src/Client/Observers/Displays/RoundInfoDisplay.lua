local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local Value = Fusion.Value
local Cleanup = Fusion.Cleanup
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)
local Timer = require(ReplicatedStorage.Client.UI.Components.Timer)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)

local gameRules = ReplicatedStorage.Assets.Configuration.GameRules

local ANCESTORS = { workspace }

local function ScaleOut(props)
    return New "UIScale" {
        Name = "ScaleOut",
        Scale = Spring(Computed(function()
            return if Unwrap(props.Visible) then 1 else 0
        end), 10, 0.8)
    }
end

local function RoundInfoDisplay()
    local roundTimerDuration = Value(0)
    local roundTimerStart = Value(0)
    local timeRemaining = Value(0)
    local roundsRemaining = Value(nil)

    local timerConnection = RunService.Heartbeat:Connect(function()
        local currentRoundTimerStart = roundTimerStart:get()

        if not currentRoundTimerStart then
            timeRemaining:set(0)
            return
        end

        if currentRoundTimerStart == 0 then
            timeRemaining:set(0)
            return
        end

        local elapsed = workspace:GetServerTimeNow() - currentRoundTimerStart
        timeRemaining:set(math.max(roundTimerDuration:get() - elapsed, 0))
    end)

    RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, roundTimerStart, "roundTimer")
    RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, roundTimerDuration, "roundDuration")
    RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, roundsRemaining, "roundsRemaining")

    return Observers.observeTag("RoundInfoDisplay", function(parent: Instance)
        local ui = Background {
            Parent = parent,
            Archivable = false,

            [Children] = {
                New "UIListLayout" {
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    Padding = UDim.new(0, 12)
                },

                Timer {
                    LayoutOrder = 1,
                    Time = timeRemaining,
                    UrgencyStart = 8,
                    TextScaled = true,

                    [Children] = ScaleOut {
                        Visible = Computed(function()
                            return timeRemaining:get() > 0
                        end)
                    }
                },

                Label {
                    TextScaled = true,

                    Text = Computed(function()
                        if not roundsRemaining:get() then
                            return ""
                        end

                        return `Round {gameRules:GetAttribute("rounds") - roundsRemaining:get()} / {gameRules:GetAttribute("rounds")}`
                    end),

                    [Children] = ScaleOut {
                        Visible = Computed(function()
                            local value = roundsRemaining:get()
                            return value ~= nil
                        end)
                    }
                }
            },

            [Cleanup] = {
                timerConnection
            }
        }

        return function()
            ui:Destroy()
        end
    end, ANCESTORS)
end

return RoundInfoDisplay