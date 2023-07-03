local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local InsertService = game:GetService("InsertService")

local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local RateLimiter = require(ServerStorage.Server.Util.RateLimiter)
local CreateLogger = require(ReplicatedStorage.Shared.CreateLogger)
local BundleUtil = require(ReplicatedStorage.Shared.Util.BundleUtil)
local GearPropUtil = require(ServerStorage.Server.Util.GearPropUtil)
local HumanoidDescriptionAssetFields = require(ServerStorage.Server.Data.HumanoidDescriptionAssetFields)

-- this is not scalable
local LAYERED_CLOTHING_TYPES = {
    ["ShirtAccessory"] = true,
    ["TShirtAccessory"] = true,
    ["PantsAccessory"] = true,
    ["LeftShoeAccessory"] = true,
    ["RightShoeAccessory"] = true,
    ["SkirtAccessory"] = true,
    ["SweaterAccessory"] = true,
    ["ShortsAccessory"] = true
}

local logger = CreateLogger(script)

local function AvatarRequestListener()
    local network = Red.Server(NetworkNamespaces.AVATAR)
    local unequipRateLimiter = RateLimiter.new(5, 1)
    local equipRateLimiter = RateLimiter.new(8, 5)

    network:On("Unequip", function(player: Player, itemId: number?, assetType: string?, bundleType: string?)
        if not unequipRateLimiter:LogRequest(player) then
            warn(`Rate limited {player} ({player.UserId})`)
            return false
        end

        local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
        local description = humanoid and humanoid:GetAppliedDescription()

        if not description then
            return false
        end

        if assetType == "Gear" then
            local prop = GearPropUtil.GetPropFromPlayer(player)

            if prop then
                prop:Destroy()
            end

            return true, true
        elseif assetType == "EmoteAnimation" then
            description:RemoveEmote(itemId)
            return true
        elseif LAYERED_CLOTHING_TYPES[assetType] then
            local accessorySpecifications = description:GetAccessories(false)
            local isChanged = false

            for index, item in accessorySpecifications do
                if item.AssetId == itemId then
                    accessorySpecifications[index] = nil
                    isChanged = true
                end
            end

            if not isChanged then
                return false
            end

            description:SetAccessories(accessorySpecifications, false)
            humanoid:ApplyDescription(description, Enum.AssetTypeVerification.Always)
            return true
        else
            local isOverwritten = pcall(function()
                description[assetType] = nil
            end)

            if isOverwritten then
                humanoid:ApplyDescription(description, Enum.AssetTypeVerification.Always)
                return true
            else
                return false
            end
        end
    end)

    network:On("Equip", function(player: Player, itemId: number?, assetType: string?, bundleType: string?)
        if not equipRateLimiter:LogRequest(player) then
            warn(`Rate limited {player} ({player.UserId})`)
            return false
        end

        print("plr", player, "itemId", itemId, "assetType", assetType, "bundleType", bundleType)

        if bundleType and MarketplaceService:PlayerOwnsBundle(player, itemId) == false then
            warn(`{player} ({player.UserId}) does not own the requested bundle {itemId}`)
            return false
        elseif assetType and MarketplaceService:PlayerOwnsAsset(player, itemId) == false then
            warn(`{player} ({player.UserId}) does not own the requested asset {itemId}`)
            return false
        end

        local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
        local description = humanoid and humanoid:GetAppliedDescription()

        if not description then
            return false
        end

        if assetType == "Gear" then
            local gear = InsertService:LoadAsset(itemId):GetChildren()[1]
            local backpack = player:FindFirstChildWhichIsA("Backpack")

            if backpack and gear and gear:IsA("Tool") then
                local prop = GearPropUtil.Propify(gear)
                local currentProp = GearPropUtil.GetPropFromPlayer(player)

                if currentProp then
                    currentProp:Destroy()
                end

                prop.CanBeDropped = false
                prop.Parent = if player.Character then player.Character else backpack

                return true, true
            else
                return false
            end
        elseif assetType == "EmoteAnimation" then
            description:AddEmote(itemId, itemId)
            return true
        elseif LAYERED_CLOTHING_TYPES[assetType] then
            local accessorySpecifications = description:GetAccessories(false)
            accessorySpecifications[#accessorySpecifications + 1] = {
                Order = 1,
                AssetId = itemId,
                AccessoryType = Enum.AccessoryType[string.gsub(assetType, "Accessory", "")],
                IsLayered = true
            }
            local isUpdateSuccessful = pcall(
                description.SetAccessories,
                description,
                accessorySpecifications,
                false
            )

            if isUpdateSuccessful then
                humanoid:ApplyDescription(description, Enum.AssetTypeVerification.Always)
            end

            print("response", isUpdateSuccessful)
            return isUpdateSuccessful
        elseif bundleType then
            local bundleDescription = BundleUtil.GetBundleDescription(itemId)
            humanoid:ApplyDescription(bundleDescription, Enum.AssetTypeVerification.Always)
            return true
        else
            local field = HumanoidDescriptionAssetFields[assetType] or assetType

            local ok, err = pcall(function()
                description[field] = itemId
            end)

            if ok then
                humanoid:ApplyDescription(description, Enum.AssetTypeVerification.Always)
                return true
            else
                logger.warn(`Failed to equip {assetType} ({itemId}) for {player} ({player.UserId}): {err}`)
                return false
            end
        end
    end)
end

return AvatarRequestListener