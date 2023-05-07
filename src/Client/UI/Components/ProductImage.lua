local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Hydrate = Fusion.Hydrate
local New = Fusion.New

local function ProductImage(props)
    local productImage = New "ImageLabel" {
        Name = "ProductImage",
        BackgroundTransparency = 1,
        ScaleType = Enum.ScaleType.Fit
    }

    return Hydrate(productImage)(props)
end

return ProductImage