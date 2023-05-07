local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)

local ANCESTORS = { workspace }

local sleep = Promise.promisify(task.wait)

local function PriceRevealDisplay()
    return Observers.observeTag("PriceRevealDisplay", function(parent: Instance)
        local ui = Value(nil)
        local isPriceRevealPhase = Value(false)
        local revealPrice = Value(nil)
        local animationPromise = nil :: typeof(Promise.new())

        local uiPosition = Spring(Computed(function()
            return if isPriceRevealPhase:get() then UDim2.new() else UDim2.fromScale(0, -1)
        end), 10)

        local function DoAnimation()
            local text = Value("The price is...")
            local backgroundColor = Value("background")
            local textColor = Value(ThemeProvider:GetColor("header"):get())
            local textColorSpring = Spring(textColor, 10)

            if animationPromise then
                animationPromise:cancel()
                animationPromise = nil
            end

            local newUi = Background {
                Position = uiPosition,

                BackgroundColor3 = Spring(Computed(function()
                    return ThemeProvider:GetColor(backgroundColor:get()):get()
                end), 20),

                [Children] = {
                    Header {
                        Size = UDim2.fromScale(1, 1),
                        AutomaticSize = Enum.AutomaticSize.None,
                        Text = text,
                        TextColor3 = textColorSpring,
                        TextScaled = true,
                    },

                    ShorthandPadding { Padding = UDim.new(0, 12) }
                }
            }

            local function Reveal()
                backgroundColor:set("accent")
                textColor:set(ThemeProvider:GetColor("accent_contrast_header"):get())
                text:set(`R${revealPrice:get()}!`)
            end

            animationPromise = Promise.resolve()
                :finallyCall(sleep, 3)
                :finallyCall(Reveal, 3)
                :catch(warn)

            ui:set(newUi)
        end

        local stopObservingRoundState = RoundStateContainer:Observe(function(oldState, newState)
            if oldState.phase == newState.phase then
                return
            end

            if newState.price then
                revealPrice:set(newState.price)
            end

            if newState.phase == "PriceReveal" then
                isPriceRevealPhase:set(true)
                DoAnimation()
            else
                isPriceRevealPhase:set(false)
            end
        end)

        local frame = Nest {
            Parent = parent,
            [Children] = { ui }
        }

        return function()
            stopObservingRoundState()
            frame:Destroy()
        end
    end, { workspace })
end

return PriceRevealDisplay