local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed

local Header = require(ReplicatedStorage.Client.UI.Components.Header)
local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local RoundStateContainer = require(ReplicatedStorage.Client.StateContainers.RoundStateContainer)
local Red = require(ReplicatedStorage.Packages.Red)

local ANCESTORS = { workspace }

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
        local binAdd, binEmpty = Red.Bin()
        local currentProductData = Value(nil)
        local winnerName = Value(nil)
        local currentPhase = Value(nil)

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

            if data.year and data.type then
                if data.year <= currentYear - 13 then
                    return `Old {cleanType} from {data.year}`
                elseif data.year <= currentYear - 8 then
                    return `A classic {cleanType} from {data.year}`
                else
                    return `{cleanType}, from {data.year}`
                end
            end

            return if data.type then cleanType else nil
        end)

        binAdd(RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, currentProductData, "productData"))
        binAdd(RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, winnerName, "winnerName"))
        binAdd(RoundStateContainer.FusionUtil.StateHook(RoundStateContainer, currentPhase, "phase"))

        local frame = Background {
            Parent = parent,

            [Children] = {
                Header {
                    Size = UDim2.fromScale(1, 0.6),

                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextScaled = true,

                    AutomaticSize = Enum.AutomaticSize.None,

                    Text = Computed(function()
                        local phase = currentPhase:get()

                        if phase == "Intermission" then
                            return "Intermission"
                        elseif phase == "GameOver" then
                            local winner = winnerName:get()
                            return if winner then `{winner} won the game!` else ""
                        else
                            return currentProductName:get() or ""
                        end
                    end)
                },

                Header {
                    Position = UDim2.fromScale(0, 1),
                    AnchorPoint = Vector2.new(0, 1),
                    Size = UDim2.fromScale(1, 0.4),

                    TextTransparency = 0.5,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextScaled = true,

                    AutomaticSize = Enum.AutomaticSize.None,

                    Text = Computed(function()
                        local phase = currentPhase:get()

                        if phase == "Intermission" then
                            return "A new game will start shortly."
                        elseif phase == "GameOver" then
                            return "Thanks for playing!"
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