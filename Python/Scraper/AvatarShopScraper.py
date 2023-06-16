import requests
import time
import json
from urllib.error import HTTPError
from enum import Enum

# https://devforum.roblox.com/t/collected-list-of-apis/557091
# https://catalog.roblox.com/docs/index.html
# https://create.roblox.com/docs/projects/assets/api
V1_SEARCH_ENDPOINT = "https://catalog.roblox.com/v1/search/items/details"
V2_SEARCH_ENDPOINT = "https://catalog.roblox.com/v2/search/items/details"
RESULTS_PER_PAGE = 120

class MarketplaceSearch():
    category: str = None
    subcategory: str = None

    def __init__(self, category, subcategory):
        self.category = category
        self.subcategory = subcategory

class MarketplaceSearches(Enum): # not exhaustive, but good enough for our use case
    gear = MarketplaceSearch(category="Accessories", subcategory="Gear")
    accessories = MarketplaceSearch(category="Accessories", subcategory=None)
    bodyParts = MarketplaceSearch(category="BodyParts", subcategory=None)
    characters = MarketplaceSearch(category="Characters", subcategory=None)
    animations = MarketplaceSearch(category="AvatarAnimations", subcategory="AvatarAnimations")
    all = MarketplaceSearch(category="All", subcategory=None)
    clothing = MarketplaceSearch(category="Clothing", subcategory="Clothing")

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

class MarketplaceCategories(Enum): # not exhaustive, but good enough for our use case
    featured = 0
    all = 1
    collectibles = 2
    clothing = 3
    bodyParts = 4
    gear = 5
    accessories = 11
    avatarAnimations = 12
    communityCreations = 13

# Roblox hasn't provided a way of getting up-to-date pricing information for bundles
# in-engine, so we'll need to store them
cachePricesFor = { "Bundle": True }

def Scrape(targetSubcategories: dict, pages:int=1):
    scrape = {}
    maxCallsPerMinute = 18
    maxCallsPerSecond = 60 / maxCallsPerMinute
    estimatedCompletionTime = len(targetSubcategories) * maxCallsPerSecond * pages
    print("Estimated completion time: {:0.2f}s".format(estimatedCompletionTime))

    for categoryName, value in targetSubcategories.items():
        nextPageCursor = None
        scrape[categoryName] = []
        pageIndex = 1

        while True:
            if pageIndex > pages:
                break

            if isinstance(value, MarketplaceSearch):
                marketplaceSearch: MarketplaceSearch = value
                url = f"{V1_SEARCH_ENDPOINT}?Category={marketplaceSearch.category}&Limit=30&SortAggregation=5"

                if marketplaceSearch.subcategory:
                    url = f"{url}&Subcategory={marketplaceSearch.subcategory}"
            else:
                categoryEnum = value
                url = f"{V2_SEARCH_ENDPOINT}/?Subcategory={categoryEnum.value}&Limit=120&SortAggregation=5&CreatorTargetId=1"

            if nextPageCursor == False:
                print("No next page cursor - changing category")
                break

            if nextPageCursor:
                # Note: Hard limit for cursors is 36 pages
                url += f"&Cursor={nextPageCursor}"

            print(f"GET request '{url}' for {categoryName} ({pageIndex}/{pages})")
            response = requests.get(url)

            if not response.ok:
                if response.status_code == 429:
                    print("Rate limited - waiting before trying again (30s)")
                    time.sleep(30)
                    continue
                elif response.status_code == 500:
                    print("Internal server error - trying again (5s)")
                    time.sleep(5)
                else:
                    response.raise_for_status()

            pageIndex += 1
            json = response.json()
            nextPageCursor = json.get("nextPageCursor", False)
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

# scrapeResult = Scrape({
#     "collectibles": MarketplaceSubcategories.collectibles,
#     "bodyParts": MarketplaceSubcategories.bodyParts,
#     "gear": MarketplaceSubcategories.gear,
#     "accessories": MarketplaceSubcategories.accessories,
#     "faces": MarketplaceSubcategories.faces,
#     "heads": MarketplaceSubcategories.heads,
#     "bundles": MarketplaceSubcategories.bundles,
#     "clothing": MarketplaceSubcategories.clothing,
# }, pages=8)

scrapeResult = Scrape(
    {i.name: i.value for i in MarketplaceSearches},
    pages=40
)
print("Exporting scrape...")

for category, data in scrapeResult.items():
    ExportScrape(data, f"ScrapeExports/{category}.json")

ExportScrape(scrapeResult, "ScrapeExports/AvatarShopData.json")
print("Done!")