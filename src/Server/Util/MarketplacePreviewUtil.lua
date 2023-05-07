local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local InsertService = game:GetService("InsertService")
local AssetService = game:GetService("AssetService")

local catalogModels = ServerStorage.Assets.CatalogModels

local function RecursivelyAnchor(subject: Instance)
    if subject:IsA("BasePart") then
        subject.Anchored = true
    end

    for _, child in subject:GetChildren() do
        RecursivelyAnchor(child)
    end
end

local function RecursivelyDisableScripts(subject: Instance)
    if subject:IsA("Script") or subject:IsA("LocalScript") then
        subject.Enabled = false
    end

    for _, child in subject:GetChildren() do
        RecursivelyDisableScripts(child)
    end
end

local MarketplacePreviewUtil = {}
MarketplacePreviewUtil.bundlePreviewCharacterPrefab = catalogModels.BundlePreviewCharacter

function MarketplacePreviewUtil.GetHumanoidDescriptionFromBundleId(bundleId: number)
    local bundleDetails: table
    local humanoidDescription: HumanoidDescription?
    local outfitId

    do
        local ok, result = pcall(AssetService.GetBundleDetailsAsync, AssetService, bundleId)

        if ok then
            bundleDetails = result
        else
            warn(`Failed to fetch bundle details ({bundleId}): {result}`)
            return nil
        end
    end

    for _, item in bundleDetails.Items or {} do
        if item.Type == "UserOutfit" then
            outfitId = item.Id
            break
        end
    end

    if not outfitId then
        warn(`No outfit id found for bundle {outfitId}`)
        return nil
    end

    do
        local ok, result = pcall(Players.GetHumanoidDescriptionFromOutfitId, Players, outfitId)

        if ok then
            humanoidDescription = result
        else
            warn(`Failed to fetch bundle ({bundleId}) outfit ({outfitId}): {result}`)
            return nil
        end
    end

    return humanoidDescription
end

function MarketplacePreviewUtil.CreateAssetPreview(asset: Instance)
    RecursivelyAnchor(asset)
    RecursivelyDisableScripts(asset)

    if asset:IsA("Decal") or asset:IsA("Texture") then
        if asset.Name == "face" then
            local head = catalogModels.Head:Clone()
            head.DefaultFace:Destroy()
            asset.Parent = head
            return head
        else
            local decalDisplay = catalogModels.DecalDisplay:Clone()
            asset.Face = Enum.NormalId.Front
            asset.Parent = decalDisplay
            return decalDisplay
        end
    end

    if asset:IsA("ShirtGraphic") then
        local tshirtDisplay = catalogModels.ShirtGraphicDisplay:Clone()
        asset.Parent = tshirtDisplay
        return tshirtDisplay
    end

    if asset:IsA("Accessory") or asset:IsA("Tool") then
        local model = Instance.new("Model")
        model.Name = asset.Name

        for _, child in asset:GetChildren() do
            child.Parent = model
        end

        return model
    end

    if asset:IsA("SpecialMesh") and asset:FindFirstChild("AvatarPartScaleType") then
        local headPreviewRig = catalogModels.HeadPreviewRig:Clone();
        local humanoidDescription = ((headPreviewRig.Humanoid) :: Humanoid):GetAppliedDescription()
        humanoidDescription.Head = asset.MeshId
        -- HumanoidDescriptions can only be applied to descendants of a DataModel, so it will be up
        -- to the caller to call Humanoid:ApplyDescription()
        return headPreviewRig
    end

    local mannequin = catalogModels.Mannequin:Clone()

    if asset:IsA("SpecialMesh") and asset:FindFirstChild("AvatarPartScaleType") then
        asset.Parent = mannequin.Head
    else
        asset.Parent = mannequin
    end

    return mannequin
end

function MarketplacePreviewUtil.CreateAssetPreviewFromId(assetId: number)
    local asset: Instance?

    do
        local ok, result = pcall(InsertService.LoadAsset, InsertService, assetId)

        if ok then
            asset = if result then result:GetChildren()[1] else nil
        else
            warn(`Failed to fetch asset ({assetId}) with InsertService: {result}`)
            return nil
        end
    end

    return if asset then MarketplacePreviewUtil.CreateAssetPreview(asset) else nil
end

return MarketplacePreviewUtil