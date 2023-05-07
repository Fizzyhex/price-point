local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local CachedMarketplace = require(ServerStorage.Server.CachedMarketplace)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local RANDOM_GEN = Random.new()

local function PickRandomProductsAsync(productPools, count: number, onUpdate)
    local productPoolKeys = TableUtil.Keys(productPools)
    local products = {}
    local maxFailures = math.huge

    local promise = Promise.new(function(resolve, reject, onCancel)
        local failures = 0
        local successes = 0
        local isRunning = true

        onCancel(function()
            isRunning = false
        end)

        while successes < count and isRunning do
            if failures >= maxFailures then
                reject(products)
                return
            end

            local productCategory = productPoolKeys[RANDOM_GEN:NextInteger(1, #productPoolKeys)]
            local productData = productPools[productCategory]:Pop()

            local ok = CachedMarketplace:GetProductInfo(productData["id"], productData["itemType"]):andThen(
                function(productInfo)
                    successes += 1
                    table.insert(products, productInfo)
                    onUpdate(table.clone(products))
                end,

                function()
                    failures += 1
                    warn(`Failed to fetch MarketplaceInfo for product {productData["id"]}, trying another product. (failure {failures}/{maxFailures})`)
                end
            ):await()

            if not ok then
                task.wait(1)
            end
        end

        resolve(products)
    end):catch(warn)

    return promise
end

return PickRandomProductsAsync