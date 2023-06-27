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
local StateContainers = require(ReplicatedStorage.Shared.StateContainers)
local roundStateContainer = StateContainers.roundStateContainer
local Promise = require(ReplicatedStorage.Packages.Promise)

local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local SoundUtil = require(ReplicatedStorage.Shared.Util.SoundUtil)

local ANCESTORS = { workspace }
local RANDOM = Random.new()
local sleep = Promise.promisify(task.wait)

local function PriceRevealDisplay()
    return Observers.observeTag("PriceRevealDisplayOld", function(parent: Instance)
        local ui = Value(nil)
        local isPriceRevealPhase = Value(false)
        local revealPrice = Value(nil)
        local animationPromise = nil :: typeof(Promise.new())
        local flashTransparency = Spring(Value(1), 15)
        local sounds: { Sound } = {
            buildup = New "Sound" {
                Name = "DrumRoll",
                SoundId = "rbxassetid://13611319011",
                RollOffMinDistance = 500,
                SoundGroup = SoundUtil.FindSoundGroup("SFX")
            },

            reveal = New "Sound" {
                Name = "Reveal",
                SoundId = "rbxassetid://6177000613",
                RollOffMinDistance = 500,
                PlaybackSpeed = RANDOM:NextNumber(1, 1.15),
                Volume = 0.5,
                SoundGroup = SoundUtil.FindSoundGroup("SFX")
            },

            itsFree = New "Sound" {
                Name = "ItsFree",
                SoundId = "rbxassetid://130771265",
                RollOffMinDistance = 500,
                SoundGroup = SoundUtil.FindSoundGroup("SFX")
            }
        }

        local uiPosition = Spring(Computed(function()
            return if isPriceRevealPhase:get() then UDim2.new() else UDim2.fromScale(0, -1)
        end), 10)

        local function DoAnimation()
            local text = Value("The price is...")
            local backgroundColor = Value("background")
            local textColor = Value(ThemeProvider:GetColor("header"):get())
            local textColorSpring = Spring(textColor, 10)
            local displayRevealPrice = Value(false)
            local isFlashPlayed = false
            local textPositionSpring = Spring(Value(UDim2.fromScale(0.5, 0.5)), 200, 0.2)
            local animationStartPrice = if revealPrice:get() < 20 then 1000 else 0
            local revealPriceSpring = Spring(Computed(function()
                return if displayRevealPrice:get() then revealPrice:get() else animationStartPrice
            end), 5)
            local lastPriceAnimationDisplay

            if animationPromise then
                animationPromise:cancel()
                animationPromise = nil
            end

            sounds.buildup:Play()

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
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = textPositionSpring,
                                AutomaticSize = Enum.AutomaticSize.None,
                                Text = Computed(function()
                                    if displayRevealPrice:get() then
                                        local value = math.ceil(revealPriceSpring:get())

                                        if lastPriceAnimationDisplay ~= value then
                                            textPositionSpring:addVelocity(
                                                UDim2.fromOffset(RANDOM:NextNumber(-15, 15),
                                                RANDOM:NextNumber(-15, 15))
                                            )

                                            if value == revealPrice:get() then
                                                task.delay(0.8, function()
                                                    if not isFlashPlayed then
                                                        isFlashPlayed = true
                                                        local sfx = if value == 0 then sounds.itsFree else sounds.reveal
                                                        sfx:Play()
                                                        flashTransparency:addVelocity(-20)
                                                    end
                                                end)
                                            end
                                        end

                                        lastPriceAnimationDisplay = value
                                        return `R${value}`
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

        local stopObservingRoundState = roundStateContainer:Observe(function(oldState, newState)
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
            [Children] = { ui, sounds }
        }

        return function()
            stopObservingRoundState()
            frame:Destroy()
        end
    end, ANCESTORS)
end

return PriceRevealDisplay