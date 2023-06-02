local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local InsertService = game:GetService("InsertService")
local AssetService = game:GetService("AssetService")
local CachedInsertService = require(ServerStorage.Server.CachedInsertService)

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

local function GetAnimator(humanoid: Humanoid)
    return humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator", humanoid)
end

local MarketplacePreviewUtil = {}
MarketplacePreviewUtil.bundlePreviewCharacterPrefab = catalogModels.BundlePreviewCharacter

function MarketplacePreviewUtil.GetHumanoidDescriptionFromBundleId(bundleId: number): HumanoidDescription?
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

function MarketplacePreviewUtil.CreateBundlePreview(bundleDetails): Model
    local character

    if bundleDetails.BundleType == "AvatarAnimations" then
        character = catalogModels.Mannequin:Clone()
        local animationPackFolder = Instance.new("Folder")
        animationPackFolder.Name = "AnimationPack"
        CollectionService:AddTag(animationPackFolder, "AnimationCycler")

        for _, item in bundleDetails.Items or {} do
            if item.Type == "Asset" then
                local model: Model
                local ok, result = pcall(function()
                    return CachedInsertService.LoadAsset(item.Id)
                end)

                if not ok then
                    warn(`Failed to insert for bundle preview ({item.Id}): {result}`)
                    continue
                else
                    model = result
                end

                local animation = model:FindFirstChildWhichIsA("Animation", true)

                if not animation then
                    warn(`Asset {item.Id} was inserted, but an Animation instance could not be found`)
                    continue
                end

                animation.Name = item.Name
                animation.Parent = animationPackFolder
            end
        end

        animationPackFolder.Parent = GetAnimator(character.Humanoid)
    else
        local humanoidDescription = MarketplacePreviewUtil.GetHumanoidDescriptionFromBundleId(bundleDetails.Id)

        if humanoidDescription then
            character = catalogModels.BundlePreviewCharacter:Clone()
            -- You can only apply HumanoidDescriptions to descendants of a DataModel
            character.Parent = ServerStorage
            character.Humanoid:ApplyDescription(humanoidDescription)
            character.Parent = nil
        else
            character = catalogModels.Mannequin:Clone()
        end

        for _, item in bundleDetails.Items or {} do
            if item.Type == "Asset" then
                local model: Model
                local ok, result = pcall(function()
                    return CachedInsertService.LoadAsset(item.Id)
                end)

                if not ok then
                    warn(`Failed to insert for bundle preview ({item.Id}): {result}`)
                    continue
                else
                    model = result
                end

                local accessory = model:FindFirstChildWhichIsA("Accessory")

                if accessory then
                    accessory.Parent = character
                end
            end
        end

        if bundleDetails.BundleType == "DynamicHead" then
            print("Handling dynamic head")
            -- DynamicHead bundles are only meant to contain character information about the Head,
            -- so the body can end up looking strange. Replace a new character's head with the
            -- dynamic head instead.
            local newCharacter = catalogModels.Mannequin:Clone()
            newCharacter.Humanoid:ReplaceBodyPartR15(Enum.BodyPartR15.Head, character.Head)
            return newCharacter
        end

        return character
    end

    if not character then
        warn(`Failed to load character for bundle id {bundleDetails.Id}`, bundleDetails)
        return nil
    end

    return character
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

    local classPreviewPrefab = catalogModels.ClassPreviews:FindFirstChild(asset.ClassName)

    if classPreviewPrefab then
        local classPreview = classPreviewPrefab:Clone()
        asset.Parent = classPreview
        return classPreview
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

    local mannequin = catalogModels.Mannequin:Clone()

    if asset:IsA("SpecialMesh") and asset:FindFirstChild("AvatarPartScaleType") then
        asset.Parent = mannequin.Head
    else
        asset.Parent = mannequin
    end

    return mannequin
end

function MarketplacePreviewUtil.CreateHeadPreviewCharacter(assetId: number)
    local headPreviewRig = catalogModels.HeadPreviewRig:Clone();
    local humanoidDescription = ((headPreviewRig.Humanoid) :: Humanoid):GetAppliedDescription()
    humanoidDescription.Head = assetId

    -- HumanoidDescriptions can only be applied to descendants of the DataModel.
    headPreviewRig.Parent = ServerStorage
    headPreviewRig.Humanoid:ApplyDescription(humanoidDescription)
    headPreviewRig.Parent = nil

    return headPreviewRig
end

function MarketplacePreviewUtil.CreateAssetPreviewFromId(assetId: number)
    local assetInfo: table?
    local asset: Instance?

    do
        local ok, result = pcall(MarketplaceService.GetProductInfo, MarketplaceService, assetId)

        if ok then
            assetInfo = result
        else
            warn(`Failed to fetch marketplace info ({assetId}): {result}`)
            return nil
        end
    end

    if assetInfo.AssetTypeId == Enum.AssetType.Head.Value then
        return MarketplacePreviewUtil.CreateHeadPreviewCharacter(assetId)
    end

    do
        local ok, result = pcall(InsertService.LoadAsset, InsertService, assetId)

        if ok then
            asset = if result then result:GetChildren()[1] else nil
        else
            warn(`Failed to fetch asset ({assetId}) using InsertService: {result}`)
            return nil
        end
    end

    return if asset then MarketplacePreviewUtil.CreateAssetPreview(asset) else nil
end

function MarketplacePreviewUtil.CreateBundlePreviewFromId(bundleId: number)
    local bundleDetails: Instance?

    do
        local ok, result = pcall(AssetService.GetBundleDetailsAsync, AssetService, bundleId)

        if ok then
            bundleDetails = result
        else
            warn(`Failed to fetch bundle details ({bundleId}) using AssetService: {result}`)
            return nil
        end
    end

    return if bundleDetails then MarketplacePreviewUtil.CreateBundlePreview(bundleDetails) else nil
end

return MarketplacePreviewUtil