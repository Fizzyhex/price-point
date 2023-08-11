local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local StateContainers = require(ReplicatedStorage.Shared.StateContainers)
local roundStateContainer = StateContainers.roundStateContainer
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local Bin = require(ReplicatedStorage.Shared.Util.Bin)

local ANCESTORS = { workspace }
local RANDOM = Random.new()
local newGameMessages = {
    "why not go grab a drink?",
    "why not go run your bath?",
    "woo new round!!",
    "preparing freshly scraped items from the roblox catalog...",
    "this time... This time i will win.",
    "didn't you leave the oven on?"
}

local function TrimStart(str: string)
    return str:match'^%s*(.*)'
end

local function PascalToWhitespace(str: string)
    local spacedString = str:gsub("%u", function(letter)
        return " " .. letter
    end)

    return TrimStart(spacedString)
end

local function ItemTitleDisplay()
    return Observers.observeTag("ItemTitleDisplay", function(parent: Instance)
        local binAdd, binEmpty = Bin()
        local currentProductData = Value(nil)
        local winnerName = Value(nil)
        local currentPhase = Value(nil)
        local winnerPoints = Value(nil)
        local headerText = Value(nil)
        local bodyText = Value(nil)
        local titleBackgroundColor = Value(nil)

        local backgroundColorSpring = Spring(Computed(function()
            return ThemeProvider:GetColor(titleBackgroundColor:get() or "background"):get()
        end))

        local textColorSpring = Spring(Computed(function()
            local _, _, value = (backgroundColorSpring:get() :: Color3):ToHSV()
            return if value > 0.5 then Color3.new(0, 0, 0) else Color3.new(1, 1, 1)
        end))

        local currentProductName = Computed(function()
            local data = currentProductData:get()
            return if data then data.name else nil
        end)

        local currentProductInfo = Computed(function()
            local data = currentProductData:get()

            if not data then
                return nil
            end

            local currentYear = os.date("%Y")
            local cleanType = if data.type then PascalToWhitespace(data.type) else nil
            local currentAccentColor = ThemeProvider:GetColor("accent"):get()
            local formattedCleanType = cleanType and `<font color="#{currentAccentColor:ToHex()}">{cleanType}</font>`

            if data.year and data.type then
                if data.year <= currentYear - 13 then
                    return `A decade-old {formattedCleanType} from {data.year}!`
                elseif data.year <= currentYear - 8 then
                    return `A {formattedCleanType} from {data.year}!`
                elseif data.year == currentYear then
                    return `A new {formattedCleanType} from {data.year}.`
                else
                    return `A {formattedCleanType} from {data.year}.`
                end
            end

            return if data.type then formattedCleanType else nil
        end)

        binAdd(roundStateContainer.FusionUtil.StateHook(roundStateContainer, currentProductData, "productData"))
        binAdd(roundStateContainer.FusionUtil.StateHook(roundStateContainer, winnerName, "winnerName"))
        binAdd(roundStateContainer.FusionUtil.StateHook(roundStateContainer, winnerPoints, "winnerPoints"))
        binAdd(roundStateContainer.FusionUtil.StateHook(roundStateContainer, currentPhase, "phase"))
        binAdd(roundStateContainer.FusionUtil.StateHook(roundStateContainer, titleBackgroundColor, "titleBackgroundColor"))
        binAdd(roundStateContainer.FusionUtil.StateHook(roundStateContainer, bodyText, "bodyText"))
        binAdd(roundStateContainer.FusionUtil.StateHook(roundStateContainer, headerText, "headerText"))

        local frame = Background {
            Parent = parent,
            BackgroundColor3 = backgroundColorSpring,

            [Children] = {
                Header {
                    TextColor3 = textColorSpring,
                    Size = UDim2.fromScale(1, 0.5),

                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextScaled = true,

                    AutomaticSize = Enum.AutomaticSize.None,

                    Text = Computed(function()
                        if headerText:get() then
                            return headerText:get()
                        end

                        local phase = currentPhase:get()

                        if phase == "Intermission" then
                            return "Intermission"
                        elseif phase == "GameOver" then
                            local winner = winnerName:get()
                            return if winner then `{winner} won!` else ""
                        else
                            return currentProductName:get() or ""
                        end
                    end)
                },

                Header {
                    TextColor3 = textColorSpring,
                    Position = UDim2.fromScale(0, 1),
                    AnchorPoint = Vector2.new(0, 1),
                    Size = UDim2.fromScale(1, 0.5),

                    TextTransparency = 0.1,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextScaled = true,

                    AutomaticSize = Enum.AutomaticSize.None,
                    RichText = true,

                    Text = Computed(function()
                        if bodyText:get() then
                            return bodyText:get()
                        end

                        local phase = currentPhase:get()

                        if phase == "Intermission" then
                            return newGameMessages[RANDOM:NextInteger(1, #newGameMessages)]
                        elseif phase == "GameOver" then
                            if winnerPoints:get() and winnerPoints:get() > 1 then
                                return `Final score: {winnerPoints:get()}`
                            else
                                return ""
                            end
                        else
                            return currentProductInfo:get() or ""
                        end
                    end)
                },

                ShorthandPadding { Padding = UDim.new(0, 12) }
            }
        }

        binAdd(frame)

        return binEmpty
    end, ANCESTORS)
end

return ItemTitleDisplay