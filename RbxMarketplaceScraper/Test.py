from CatalogScraper import CatalogScraperV1

scraper = CatalogScraperV1(creatorTargetId=40763226)
print("result=", scraper.scrape(3))