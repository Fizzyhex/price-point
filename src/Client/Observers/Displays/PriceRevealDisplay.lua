local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Tween = Fusion.Tween

local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local GlobalEventSystem = require(ReplicatedStorage.Client.GlobalEventSystem)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)

local ANCESTORS = { workspace }

local sleep = Promise.promisify(task.wait)

local function Round(x)
    return math.floor(x + 0.5)
end

local function PriceRevealDisplay()
    return Observers.observeTag("PriceRevealDisplay", function(parent: Instance)
        local ui = Value(nil)
        local isPriceRevealPhase = Value(false)
        local revealPrice = Value(nil)
        local animationPromise = nil :: typeof(Promise.new())
        local flashTransparency = Spring(Value(1), 15)

        local uiPosition = Spring(Computed(function()
            return if isPriceRevealPhase:get() then UDim2.new() else UDim2.fromScale(0, -1)
        end), 10)

        local function DoAnimation()
            local text = Value("The price is...")
            local backgroundColor = Value("background")
            local textColor = Value(ThemeProvider:GetColor("header"):get())
            local textColorSpring = Spring(textColor, 10)
            local displayRevealPrice = Value(false)
            local revealPriceSpring = Spring(Computed(function()
                return if displayRevealPrice:get() then revealPrice:get() else 0
            end), 5)
            local lastPriceAnimationDisplay

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
                    New "Frame" {
                        Name = "Flash",
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 50,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = flashTransparency
                    },

                    Nest {
                        [Children] = {
                            Header {
                                Size = UDim2.fromScale(1, 1),
                                AutomaticSize = Enum.AutomaticSize.None,
                                Text = Computed(function()
                                    if displayRevealPrice:get() then
                                        local value = Round(revealPriceSpring:get())

                                        if lastPriceAnimationDisplay ~= value then
                                            if value == revealPrice:get() then
                                                task.delay(0.8, function()
                                                    flashTransparency:addVelocity(-20)
                                                    GlobalEventSystem.onPriceRevealed:Fire()
                                                end)
                                            end
                                        end

                                        lastPriceAnimationDisplay = value
                                        return `R${Round(revealPriceSpring:get())}`
                                    else
                                        return text:get()
                                    end
                                end),
                                TextColor3 = textColorSpring,
                                TextScaled = true,
                            },

                            ShorthandPadding { Padding = UDim.new(0, 12) }
                        }
                    }
                }
            }

            local function Reveal()
                backgroundColor:set("accent")
                textColor:set(ThemeProvider:GetColor("accent_contrast_header"):get())
                displayRevealPrice:set(true)
                text:set(`R${revealPrice:get()}!`)
            end

            animationPromise = Promise.resolve()
                :finallyCall(sleep, 3)
                :finallyCall(Reveal, 3)
                :catch(warn)

            if ui:get() then
                -- Cleanup old UI
                ui:get():Destroy()
            end

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
    end, ANCESTORS)
end

return PriceRevealDisplay