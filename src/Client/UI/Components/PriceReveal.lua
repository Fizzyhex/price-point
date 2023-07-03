local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PropsUtil = require(ReplicatedStorage.Client.UI.Util.PropsUtil)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)
local SoundUtil = require(ReplicatedStorage.Shared.Util.SoundUtil)
local Fusion = require(ReplicatedStorage.Packages.Fusion)
local NumberUtil = require(ReplicatedStorage.Shared.Util.NumberUtil)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Cleanup = Fusion.Cleanup
local Observer = Fusion.Observer

local sleep = Promise.promisify(task.wait)
local STRIPPED_PROPS = { "PlayEvent", "EndEvent", "OnFinalPriceRevealed" }
local RANDOM = Random.new()

local function PriceReveal(props)
    local currentAnimationPromise
    local currentLabel = Value(nil)
    local strippedProps = StripProps(props, STRIPPED_PROPS)
    local flashTransparencySpring = Spring(Value(1))
    local uiPosition = Value(UDim2.fromScale(0.5, -1))
    local uiPositionSpring = Spring(uiPosition, 15)
    local onEnd = Signal.new()
    local onFinalPriceRevealed = props.OnFinalPriceRevealed

    local sounds = {
        buildup = New "Sound" {
            Name = "DrumRoll",
            SoundId = "rbxassetid://13611319011",
            RollOffMinDistance = 800,
            Volume = 0.7,
            SoundGroup = SoundUtil.FindSoundGroup("SFX")
        },

        reveal = New "Sound" {
            Name = "Reveal",
            SoundId = "rbxassetid://6177000613",
            RollOffMinDistance = 800,
            PlaybackSpeed = RANDOM:NextNumber(1, 1.15),
            Volume = 0.6,
            SoundGroup = SoundUtil.FindSoundGroup("SFX")
        },

        itsFree = New "Sound" {
            Name = "ItsFree",
            SoundId = "rbxassetid://130771265",
            RollOffMinDistance = 800,
            SoundGroup = SoundUtil.FindSoundGroup("SFX")
        }
    }

    local function Play(price)
        price = Unwrap(price)
        uiPositionSpring:setPosition(UDim2.fromScale(0.5, -1))
        local isWindup = Value(true)
        local priceSpring = Spring(Value(price), 5)
        local accentColor = ThemeProvider:GetColor("accent")
        local backgroundColor = ThemeProvider:GetColor("background")
        local headerColor = ThemeProvider:GetColor("header")
        local accentContrastHeaderColor = ThemeProvider:GetColor("accent_contrast_header")
        local backgroundTransparency = Value(1)
        local binAdd, binEmpty = Bin()
        sounds.buildup:Play()

        if currentAnimationPromise then
            currentAnimationPromise:cancel()
            currentLabel:get():Destroy()
        end

        local function SetBackgroundTransparency(transparency)
            backgroundTransparency:set(transparency)
        end

        binAdd(onEnd:Connect(function()
            SetBackgroundTransparency(1)
        end))

        local destroyRevealFinishedObserver
        destroyRevealFinishedObserver = Observer(priceSpring):onChange(function()
            local roundedPrice = math.round(priceSpring:get())

            if roundedPrice == price then
                destroyRevealFinishedObserver()

                task.delay(0.5, function()
                    flashTransparencySpring:setPosition(0)

                    if onFinalPriceRevealed then
                        onFinalPriceRevealed:Fire()
                    end

                    if price == 0 then
                        sounds.itsFree:Play()
                    else
                        sounds.reveal:Play()
                    end
                end)
            end
        end)

        binAdd(destroyRevealFinishedObserver)

        local label = Background {
            BackgroundColor3 = Spring(Computed(function()
                return if isWindup:get() then backgroundColor:get() else accentColor:get()
            end)),

            BackgroundTransparency = Spring(backgroundTransparency),

            [Children] = {
                Header {
                    Text = Computed(function()
                        if isWindup:get() then
                            return "The price is..."
                        else
                            local roundedPrice = math.round(priceSpring:get())
                            local formattedPrice = NumberUtil.CommaSeperate(roundedPrice)
                            return `R${formattedPrice}`
                        end
                    end),

                    TextScaled = true,
                    AnchorPoint = Vector2.new(0.5, 0),
                    Size = UDim2.fromScale(1, 1),
                    Position = uiPositionSpring,
                    TextColor3 = Spring(Computed(function()
                        return if isWindup:get() then headerColor:get() else accentContrastHeaderColor:get()
                    end)),


                    [Cleanup] = { binEmpty }
                },

                ShorthandPadding { Padding = UDim.new(0, 12) }
            }
        }

        currentLabel:set(label)
        uiPosition:set(UDim2.fromScale(0.5, 0))

        currentAnimationPromise = Promise.resolve()
        :finallyCall(SetBackgroundTransparency, 0)
        :finallyCall(sleep, 3)
        :finallyCall(function()
            priceSpring:setPosition(if price == 0 or (price <= 25 and RANDOM:NextInteger(1, 2) == 1) then 1000 else 0)
            isWindup:set(false)
        end)
        :catch(warn)
    end

    local function Finish()
        uiPosition:set(UDim2.fromScale(0.5, 1))
        onEnd:Fire()
    end

    local playConnection = if props.PlayEvent then props.PlayEvent:Connect(Play) else nil
    local endConnection = if props.EndEvent then props.EndEvent:Connect(Finish) else nil

    local container = New("Frame")(PropsUtil.PatchProps({
        Name = "PriceReveal",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,

        [Children] = {
            New "Frame" {
                Name = "Flash",
                ZIndex = 2,
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = flashTransparencySpring
            },

            currentLabel,
            sounds
        },

        [Cleanup] = {
            function()
                if playConnection then
                    playConnection:Disconnect()
                end

                if endConnection then
                    endConnection:Disconnect()
                end
            end
        }
    }, strippedProps))

    return container
end

return PriceReveal