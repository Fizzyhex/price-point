local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local New = Fusion.New
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local PropsUtil = require(ReplicatedStorage.Client.UI.Util.PropsUtil)

local function Background(props)
    return New("Frame")(PropsUtil.PatchProps({
        Name = "Background",
        BackgroundColor3 = ThemeProvider:GetColor("background"),
        Size = UDim2.fromScale(1, 1)
    }, props))
end

return Background