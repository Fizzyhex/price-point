local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Observers = require(ReplicatedStorage.Packages.Observers)

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Value = Fusion.Value

local ProductFeedStateContainer = require(ReplicatedStorage.Client.StateContainers.ProductFeedStateContainer)
local ProductFeed = require(ReplicatedStorage.Client.UI.Components.ProductFeed)
local TableUtil = require(ReplicatedStorage.Packages.TableUtil)

local ANCESTORS = { workspace }
local TAG = "ProductFeedDisplay"

local function ProductFeedDisplay()
    local products = Value({})

    ProductFeedStateContainer:Observe(function(_, newState)
        local currentProductData = products:get()
        local newProductData = {}

        for _, productData in newState do
            local isOld = false

            for _, product in currentProductData do
                if product.id == productData.id then
                    isOld = true
                    break
                end
            end

            if isOld then
                continue
            end

            table.insert(newProductData, productData)
        end

        if #newProductData > 0 then
            products:set(TableUtil.Extend(currentProductData, newProductData))
        end
    end)

    Observers.observeTag(TAG, function(target: Instance)
        local ui = ProductFeed {
            Parent = target,
            Products = products
        }

        return function()
            -- omg it's just like horacekat
            ui:Destroy()
        end
    end, ANCESTORS)
end

return ProductFeedDisplay