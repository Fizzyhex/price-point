class MarketplaceSearch():
    category: str = None
    subcategory: str = None

    def __init__(self, category, subcategory):
        self.category = category
        self.subcategory = subcategory