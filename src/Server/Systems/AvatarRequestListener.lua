local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)
local RateLimiter = require(ServerStorage.Server.Util.RateLimiter)

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

local function AvatarRequestListener()
    local network = Red.Server(NetworkNamespaces.AVATAR, { "Equip", "Unequip" })
    local unequipRateLimiter = RateLimiter.new(5, 1)
    local equipRateLimiter = RateLimiter.new(8, 5)

    network:On("Unequip", function(player: Player, itemId: number?, assetType: string?)
        if not unequipRateLimiter:LogRequest(player) then
            warn(`Rate limited {player} ({player.UserId})`)
            return false
        end

        local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
        local description = humanoid and humanoid:GetAppliedDescription()

        if not description then
            return false
        end

        if LAYERED_CLOTHING_TYPES[assetType] then
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

    network:On("Equip", function(player: Player, itemId: number?, assetType: string?)
        if not equipRateLimiter:LogRequest(player) then
            warn(`Rate limited {player} ({player.UserId})`)
            return false
        end

        if assetType == "Bundle" and MarketplaceService:PlayerOwnsBundle(player, itemId) == false then
            warn(`{player} ({player.UserId}) does not own the requested bundle {itemId}`)
            return false
        elseif MarketplaceService:PlayerOwnsAsset(player, itemId) == false then
            warn(`{player} ({player.UserId}) does not own the requested asset {itemId}`)
            return false
        end

        local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
        local description = humanoid and humanoid:GetAppliedDescription()

        if not description then
            return false
        end

        if LAYERED_CLOTHING_TYPES[assetType] then
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
        else
            local ok = pcall(function()
                description[assetType] = itemId
            end)

            if ok then
                humanoid:ApplyDescription(description, Enum.AssetTypeVerification.Always)
                return true
            else
                warn(`Failed to equip '{assetType} ({itemId})' for {player} ({player.UserId})`)
                return false
            end
        end
    end)
end

return AvatarRequestListener