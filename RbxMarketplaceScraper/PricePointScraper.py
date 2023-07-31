import json
import os
from __init__ import CatalogScraperV1, ScrapeFilters, MarketplaceEnums

def scrape_characters(pages):
    scraper = CatalogScraperV1(
        category=MarketplaceEnums.SearchCategory.Characters,
        sortAggregation=MarketplaceEnums.SortAggregation.AllTime
    )
    scrape = scraper.scrape(pages=pages)
    filteredScrape = [item for item in scrape if ScrapeFilters.is_bundle(item)]
    return filteredScrape

def scrape_heads(pages):
    scraper = CatalogScraperV1(
        category=MarketplaceEnums.SearchCategory.BodyParts,
        sortAggregation=MarketplaceEnums.SortAggregation.AllTime
    )
    scrape = scraper.scrape(pages=pages)
    filteredScrape = [
        item
        for item in scrape 
        if 
            ScrapeFilters.is_of_asset_type(item, MarketplaceEnums.AssetType.Head)
            or ScrapeFilters.is_of_asset_type(item, MarketplaceEnums.AssetType.Face)
            or ScrapeFilters.is_of_bundle_type(item, MarketplaceEnums.BundleType.DynamicHead)
    ]
    return filteredScrape

def scrape_accessories(pages):
    is_gear = lambda x: x.get("assetType") == MarketplaceEnums.Subcategory.Gear.value
    scraper = CatalogScraperV1(
        category=MarketplaceEnums.SearchCategory.Accessories,
        sortAggregation=MarketplaceEnums.SortAggregation.AllTime,
        creatorTargetId=1,
        includeNotForSale=True
    )
    scrape = scraper.scrape(pages=pages)
    filteredScrape = [item for item in scrape if not is_gear(item)]
    return filteredScrape

def scrape_ugc(pages):
    is_ugc = lambda x: x.get("creatorTargetId") != 1
    scraper = CatalogScraperV1(
        category=MarketplaceEnums.SearchCategory.Accessories,
        sortAggregation=MarketplaceEnums.SortAggregation.AllTime,
    )
    scrape = scraper.scrape(pages=pages)
    filteredScrape = [item for item in scrape if is_ugc(item)]
    return filteredScrape

def scrape_collectibles(pages):
    scraper = CatalogScraperV1(
        category=MarketplaceEnums.Category.All,
        salesTypeFilter=MarketplaceEnums.SalesTypeFilter.Collectibles,
        creatorTargetId=1
    )
    scrape = scraper.scrape(pages=pages)
    return scrape

def scrape_clothing(pages):
    scraper = CatalogScraperV1(
        category=MarketplaceEnums.Category.Clothing,
        creatorTargetId=1
    )
    scrape = scraper.scrape(pages=pages)
    return scrape

def scrape_gear(pages):
    scraper = CatalogScraperV1(
        category=MarketplaceEnums.SearchCategory.Accessories,
        subcategory=MarketplaceEnums.Subcategory.Gear,
        sortAggregation=MarketplaceEnums.SortAggregation.AllTime
    )
    scrape = scraper.scrape(pages=pages)
    return scrape

def scrpae_avatar_animations(pages):
    scraper = CatalogScraperV1(
        category=MarketplaceEnums.SearchCategory.AvatarAnimations,
        sortAggregation=MarketplaceEnums.SortAggregation.AllTime
    )
    scrape = scraper.scrape(pages=pages)
    return scrape

def export_scrape(data, fileName):
    exportPath = "Scrape"

    if not os.path.exists(exportPath):
        os.makedirs(exportPath)

    print(f"Dumping {len(data)} scraped items to file...")
    
    with open(f"{exportPath}/{fileName}", "w", encoding="utf-8") as file:
        json.dump(data, file, ensure_ascii=False)

def run_scrape():
    pages = 40

    def handle_scrape(scrape, fileName):
        return export_scrape(ScrapeFilters.strip_for_roblox(scrape), fileName)

    handle_scrape(scrape_ugc(pages=pages), "UGC.json")
    handle_scrape(scrape_accessories(pages=pages), "Accessories.json")
    handle_scrape(scrape_heads(pages=pages), "Heads.json")
    handle_scrape(scrape_characters(pages=pages), "Characters.json")
    handle_scrape(scrape_collectibles(pages=pages), "Collectibles.json")
    handle_scrape(scrape_clothing(pages=pages), "Clothing.json")
    handle_scrape(scrape_gear(pages=pages), "Gear.json")
    handle_scrape(scrpae_avatar_animations(pages=pages), "Animations.json")

run_scrape()
print("Done!")