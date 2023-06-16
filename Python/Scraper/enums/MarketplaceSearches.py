class MarketplaceSearches(Enum): # not exhaustive, but good enough for our use case
    gear = MarketplaceSearch(category="Accessories", subcategory="Gear")
    accessories = MarketplaceSearch(category="Accessories", subcategory=None)
    bodyParts = MarketplaceSearch(category="BodyParts", subcategory=None)
    characters = MarketplaceSearch(category="Characters", subcategory=None)
    animations = MarketplaceSearch(category="AvatarAnimations", subcategory="AvatarAnimations")
    all = MarketplaceSearch(category="All", subcategory=None)
    clothing = MarketplaceSearch(category="Clothing", subcategory="Clothing")