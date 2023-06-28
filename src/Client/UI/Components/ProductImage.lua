local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PropsUtil = require(ReplicatedStorage.Client.UI.Util.PropsUtil)
local Hydrate = Fusion.Hydrate
local New = Fusion.New

local function ProductImage(props)
    return New("ImageLabel")(PropsUtil.PatchProps({
        Name = "ProductImage",
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit
    }, props))
end

return ProductImage