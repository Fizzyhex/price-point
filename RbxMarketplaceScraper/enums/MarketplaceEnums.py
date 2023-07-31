from enum import Enum

class BundleType(Enum):
    BodyParts = 1
    Animations = 2
    Shoes = 3
    DynamicHead = 4
    DynamicHeadAvatar = 5

class AssetType(Enum):
    TShirt = 2
    Audio = 3
    Mesh = 4
    Lua = 5
    Hat = 8
    Place = 9
    Model = 10
    Shirt = 11
    Pants = 12
    Decal = 13
    Head = 17
    Face = 18
    Gear = 19
    Badge = 21
    Animation = 24
    Torso = 27
    RightArm = 28
    LeftArm = 29
    LeftLeg = 30
    RightLeg = 31
    Package = 32
    GamePass = 34
    Plugin = 38
    MeshPart = 40
    HairAccessory = 41
    FaceAccessory = 42
    NeckAccessory = 43
    ShoulderAccessory = 44
    FrontAccessory = 45
    BackAccessory = 46
    WaistAccessory = 47
    ClimbAnimation = 48
    DeathAnimation = 49
    FallAnimation = 50
    IdleAnimation = 51
    JumpAnimation = 52
    RunAnimation = 53
    SwimAnimation = 54
    WalkAnimation = 55
    PoseAnimation = 56
    MoodAnimation = 78
    EarAccessory = 57
    EyeAccessory = 58
    EmoteAnimation = 61
    Video = 62
    TShirtAccessory = 64
    ShirtAccessory = 65
    PantsAccessory = 66
    JacketAccessory = 67
    SweaterAccessory = 68
    ShortsAccessory = 69
    LeftShoeAccessory = 70
    RightShoeAccessory = 71
    DressSkirtAccessory = 72
    EyebrowAccessory = 76
    EyelashAccessory = 77
    DynamicHead = 79
    FontFamily = 73

class Subcategory(Enum):
    Featured = 0 
    All = 1 
    Collectibles = 2 
    Clothing = 3 
    BodyParts = 4 
    Gear = 5 
    Hats = 9 
    Faces = 10
    Shirts = 12
    TShirts = 13
    Pants = 14
    Heads = 15
    Accessories = 19
    HairAccessories = 20
    FaceAccessories = 21
    NeckAccessories = 22
    ShoulderAccessories = 23
    FrontAccessories = 24
    BackAccessories = 25
    WaistAccessories = 26
    AvatarAnimations = 27
    Bundles = 37
    AnimationBundles = 38
    EmoteAnimations = 39
    CommunityCreations = 40
    Melee = 41
    Ranged = 42
    Explosive = 43
    PowerUp = 44
    Navigation = 45
    Musical = 46
    Social = 47
    Building = 48
    Transport = 49

class SortType(Enum):
    Relevance = 0
    Favorited = 1
    Sales = 2
    Updated = 3
    PriceAsc = 4
    PriceDesc = 5

class SortAggregation(Enum):
    PastDay = 1
    PastWeek = 3
    PastMonth = 4
    AllTime = 5

class Category(Enum):
    Featured = 0
    All = 1
    Collectibles = 2
    Clothing = 3
    BodyParts = 4
    Gear = 5
    Accessories = 1
    AvatarAnimations = 2
    CommunityCreations = 3

class SearchCategory(Enum):
    Characters = "Characters"
    Clothing = "Clothing"
    Accessories = "Accessories"
    AvatarAnimations = "AvatarAnimations"
    BodyParts = "BodyParts"

class SearchSubcategory(Enum):
    DynamicHeads = "DynamicHeads"
    Heads = "Heads"

class SalesTypeFilter(Enum):
    All = 1
    Collectibles = 2
    Premium = 3