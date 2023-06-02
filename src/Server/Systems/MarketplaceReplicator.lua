local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.Red)
local NetworkNamespaces = require(ReplicatedStorage.Shared.Constants.NetworkNamespaces)

local function MarketplaceReplicator()
    local network = Red.Server(
        NetworkNamespaces.MARKETPLACE_REPLICATION,
        { "OnPurchase" }
    )

    MarketplaceService.PromptBundlePurchaseFinished:Connect(function(player: Player, bundleId, wasPurchased: boolean)
        if not wasPurchased then
            return
        end

        network:Fire(player, "OnPurchase", "Bundle", bundleId)
    end)

    MarketplaceService.PromptPurchaseFinished:Connect(function(player: Player, assetId, wasPurchased: boolean)
        if not wasPurchased then
            return
        end

        network:Fire(player, "OnPurchase", "Asset", assetId)
    end)
end

return MarketplaceReplicator