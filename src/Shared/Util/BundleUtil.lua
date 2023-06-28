local AssetService = game:GetService("AssetService")
local Players = game:GetService("Players")

local BundleUtil = {}

function BundleUtil.GetBundleDescription(bundleId: string | number)
    local bundleInfo = AssetService:GetBundleDetailsAsync(bundleId)
    local outfitId

    -- Find the outfit that corresponds with this bundle.
    for _, item in pairs(bundleInfo.Items) do
        if item.Type == "UserOutfit" then
            outfitId = item.Id
            break
        end
    end

    return if outfitId then Players:GetHumanoidDescriptionFromOutfitId(outfitId) else nil
end

return BundleUtil