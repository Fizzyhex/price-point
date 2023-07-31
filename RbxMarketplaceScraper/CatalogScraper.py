import time
import requests

from enums.MarketplaceEnums import SortAggregation

def build_query(dict):
    return "&".join([f"{index}={value}" for index, value in dict.items()])

class CatalogScraperV1():
    HARD_CURSOR_LIMIT = 36

    def __init__(
        self,
        category=None,
        subcategory=None,
        sortAggregation=SortAggregation.AllTime,
        creatorTargetId=None,
        salesTypeFilter=None,
        includeNotForSale:bool=None,
    ):
        self._data = []
        self._currentPage = 0
        self._pageCursor = None
        self._category = category
        self._subcategory = subcategory
        self._sortAggregation = sortAggregation
        self._creatorTargetId = creatorTargetId
        self._salesTypeFilter = salesTypeFilter
        self._includeNotForSale = includeNotForSale

    def scrape(self, pages):
        result = []

        while self._currentPage < pages:
            if self.is_limit_hit():
                print(f"Hit cursor limit at {self._currentPage} requests - cannot scrape any further")
                break

            print(f"Scraping page {self._currentPage + 1}/{pages}...")
            result += self.next_page()
            time.sleep(1)

        return result

    def is_limit_hit(self):
        return self._currentPage > 0 and self._pageCursor == None

    def next_page(self):
        queries = {"limit": 30}
        endpoint = "https://catalog.roblox.com/v1/search/items/details"
        
        if self.is_limit_hit():
            return []

        if self._pageCursor:
            queries["cursor"] = self._pageCursor

        if self._category:
            queries["category"] = self._category.name

        if self._subcategory:
            queries["subcategory"] = self._subcategory.name

        if self._sortAggregation:
            queries["sortAggregation"] = self._sortAggregation.value

        if self._creatorTargetId:
            queries["creatorTargetId"] = self._creatorTargetId

        if self._salesTypeFilter:
            queries["salesTypeFilter"] = self._salesTypeFilter.value

        if self._includeNotForSale:
            queries["includeNotForSale"] = True
        
        url = f"{endpoint}?{build_query(queries)}"
        print(f"Making web request {url}")

        with requests.get(url) as response:
            if not response.ok:
                if response.status_code == 429:
                    print("Rate limited - waiting before trying again (30s)")
                    time.sleep(30)
                    return self.next_page()
                elif response.status_code == 500:
                    print("Internal server error on Roblox's end - trying again (5s)")
                    time.sleep(5)
                    return self.next_page()
                else:
                    print(f"Unhandled error {response.status_code}: {response.text}")
                    print("Trying again in 10s")
                    time.sleep(10)
                    return self.next_page()

            self._currentPage += 1
            json = response.json()
            self._pageCursor = json.get("nextPageCursor", None)
            return json.get("data", [])