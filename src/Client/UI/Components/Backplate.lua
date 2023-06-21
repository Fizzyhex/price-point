local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PropsUtil = require(ReplicatedStorage.Client.UI.Util.PropsUtil)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local New = Fusion.New
local Children = Fusion.Children

local function Backplate(props)
    local backplateProps = {
        BackgroundColor3 = ThemeProvider:GetColor("background_3"),
        BackgroundTransparency = 0.1,

        [Children] = {
            New "UICorner" {
                CornerRadius = UDim.new(0, 8)
            },

            ShorthandPadding { Padding = UDim.new(0, 12) }
        }
    }

    return New("Frame")(PropsUtil.PatchProps(backplateProps, props))
end

return Backplate