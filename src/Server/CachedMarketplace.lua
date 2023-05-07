local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)

local GetMarketplaceInfoAsync = Promise.promisify(function(assetId: number, infoType: Enum.InfoType)
    return MarketplaceService:GetProductInfo(assetId, infoType)
end)

local productInfoCache = {}

-- Version of MarketplaceService wich caching and promises
local CachedMarketplace = {}

function CachedMarketplace:GetProductInfo(assetId: number, infoType: Enum.InfoType)
    if not CachedMarketplace[infoType] then
        CachedMarketplace[infoType] = {}
    end

    local key = tostring(assetId)
    local cached = productInfoCache[key]

    if cached then
        return Promise.resolve(cached)
    else
        return GetMarketplaceInfoAsync(assetId, infoType)
    end
end

return CachedMarketplace