is_bundle = lambda item: item.get("bundleType")
is_asset = lambda item: item.get("assetType")
is_of_asset_type = lambda item, *types: any(assetType for assetType in types if assetType.value == item.get("assetType"))
is_of_bundle_type = lambda item, *types: any(bundleType for bundleType in types if bundleType.value == item.get("bundleType"))

def strip_for_roblox(data: list):
    result = []

    for product in data:
        if product.get("bundleType"):
            result.append({
                "id": product.get("id"),
                "itemType": product.get("itemType"),
                "bundleType": product.get("bundleType"),
                "price": product.get("price")
            })
        elif product.get("assetType"):
            result.append({
                "id": product.get("id"),
                "itemType": product.get("itemType"),
                "assetType": product.get("assetType")
            })
    
    return result