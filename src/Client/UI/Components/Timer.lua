local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local Computed = Fusion.Computed

local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)

local STRIPPED_PROPS = { "Time" }

local function Timer(props)
    local timeValue = props.Time

    local label = Label {
        Text = Computed(function()
            return math.floor(Unwrap(timeValue) or 0)
        end)
    }

    return Hydrate(label)(StripProps(props, STRIPPED_PROPS))
end

return Timer