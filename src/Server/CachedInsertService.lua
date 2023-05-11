local InsertService = game:GetService("InsertService")

local insertionCache = {}

local CachedInsertService = {}

function CachedInsertService.LoadAsset(assetId: number)
    if insertionCache[assetId] then
        return insertionCache[assetId]:Clone()
    end

    local asset = InsertService:LoadAsset(assetId)
    insertionCache[assetId] = asset

    return asset:Clone()
end

return CachedInsertService