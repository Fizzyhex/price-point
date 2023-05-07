import requests
import time
import json
from urllib.error import HTTPError
from enum import Enum

# https://devforum.roblox.com/t/collected-list-of-apis/557091
# https://catalog.roblox.com/docs/index.html
SEARCH_ENDPOINT = "https://catalog.roblox.com/v2/search/items/details"

class MarketplaceSubcategories(Enum): # not exhaustive, but good enough for our use case
    featured = 0
    all = 1
    collectibles = 2
    clothing = 3
    bodyParts = 4
    gear = 5
    hats = 9
    faces = 10
    shirts = 12
    tshirts = 13
    pants = 14
    heads = 15
    accessories = 19
    hairAccessories = 20
    bundles = 37
    animationBundles = 38

# Roblox still hasn't provided a way of getting up-to-date pricing information for bundles...
cachePricesFor = { "Bundle": True }

def Scrape(targetSubcategories: dict, pages:int=1):
    scrape = {}
    maxCallsPerMinute = 20
    maxCallsPerSecond = 60 / maxCallsPerMinute
    estimatedCompletionTime = len(targetSubcategories) * maxCallsPerSecond * pages

    print("Estimated completion time: {:0.2f}s".format(estimatedCompletionTime))

    for categoryName, categoryId in targetSubcategories.items():
        nextPageCursor = None
        scrape[categoryName] = []

        for pageIndex in range(1, pages):
            url = f"{SEARCH_ENDPOINT}/?Subcategory={categoryId}&Limit=120&SortAggregation=5&CreatorTargetId=1"

            if nextPageCursor:
                # Note: Hard limit for cursors is 36 pages
                url += f"&Cursor={nextPageCursor}"

            print(f"GET request '{url}' for {categoryName} ({pageIndex}/{pages})")
            response = requests.get(url)

            if not response.ok:
                if response.status_code == 429:
                    print("Rate limited - waiting before trying again (15s)")
                    time.sleep(15)
                else:
                    response.raise_for_status()

            json = response.json()
            nextPageCursor = json.get("nextPageCursor")

            entries = []

            for productData in json["data"]:
                info = {
                    "id": productData["id"],
                    "itemType": productData["itemType"],
                }

                if cachePricesFor.get(productData["itemType"]):
                    info["price"] = productData["price"]

                entries.append(info)

            scrape[categoryName] += entries
            time.sleep(maxCallsPerSecond)
    
    return scrape

def ExportScrape(scrape: list, filePath: str):
    with open(filePath, "w") as file:
        json.dump(scrape, file)

scrapeResult = Scrape({
    "collectibles": MarketplaceSubcategories.collectibles,
    "bodyParts": MarketplaceSubcategories.bodyParts,
    "gear": MarketplaceSubcategories.gear,
    "accessories": MarketplaceSubcategories.accessories,
    "faces": MarketplaceSubcategories.faces,
    "heads": MarketplaceSubcategories.heads,
    "bundles": MarketplaceSubcategories.bundles,
    "clothing": MarketplaceSubcategories.clothing,
}, pages=4)

print("Exporting scrape...")
ExportScrape(scrapeResult, "AvatarShopData.json")
print("Done!")