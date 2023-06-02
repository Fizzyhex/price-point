local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local Computed = Fusion.Computed
local Value = Fusion.Value
local Spring = Fusion.Spring
local Out = Fusion.Out
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup

local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)

local STRIPPED_PROPS = { "Time", "UrgencyStart" }

local function Timer(props)
    local timeValue = props.Time
    local text = Value()
    local urgencyStart = props.UrgencyStart or -10
    local bodyColor = ThemeProvider:GetColor("body")
    local textColor = Spring(bodyColor)

    local label = Label {
        Text = Computed(function()
            return math.floor(Unwrap(timeValue) or 0)
        end),
        [Out "Text"] = text,
        TextColor3 = textColor,

        [Cleanup] = {
            Observer(text):onChange(function()
                if timeValue:get() <= Unwrap(urgencyStart) then
                    textColor:setPosition(Color3.new(1, 0.3, 0.3))
                end
            end),
        }
    }

    return Hydrate(label)(StripProps(props, STRIPPED_PROPS))
end

return Timer