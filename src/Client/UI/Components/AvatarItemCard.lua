local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local New = Fusion.New
local Hydrate = Fusion.Hydrate
local Children = Fusion.Children
local Value = Fusion.Value
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Cleanup = Fusion.Cleanup

local Background = require(ReplicatedStorage.Client.UI.Components.Background)
local StripProps = require(ReplicatedStorage.Client.UI.Util.StripProps)
local Label = require(ReplicatedStorage.Client.UI.Components.Label)
local ThemeProvider = require(ReplicatedStorage.Client.UI.Util.ThemeProvider)
local Icon = require(ReplicatedStorage.Client.UI.Components.Icon)
local ProductImage = require(ReplicatedStorage.Client.UI.Components.ProductImage)
local ShorthandPadding = require(ReplicatedStorage.Client.UI.Components.ShorthandPadding)
local Nest = require(ReplicatedStorage.Client.UI.Components.Nest)
local HorizontalListLayout = require(ReplicatedStorage.Client.UI.Components.HorizontalListLayout)
local VerticalListLayout = require(ReplicatedStorage.Client.UI.Components.VerticalListLayout)
local IconContainer = require(ReplicatedStorage.Client.UI.Components.IconContainer)
local PrimaryButton = require(ReplicatedStorage.Client.UI.Components.PrimaryButton)
local Unwrap = require(ReplicatedStorage.Client.UI.Util.Unwrap)

local STRIPPED_PROPS = {
    "Id",
    "AvatarItemType",
    "ItemDetails",
    "EquipCallback",
    "UnequipCallback"
}

local function AvatarItemCard(props)
    local id = Value(Unwrap(props.Id))
    local avatarItemType = props.AvatarItemType
    local itemDetails = Value(Unwrap(props.ItemDetails))
    local isEquipped = Value(false)
    local detailsHidden = props.DetailsHidden or Value(false)
    local equipCallback = props.EquipCallback
    local unequipCallback = props.UnequipCallback
    local cleanup = {}

    local isOwned = Computed(function()
        if itemDetails:get() then
            return itemDetails:get().Owned
        else
            return false
        end
    end)

    local itemName = Computed(function()
        if itemDetails:get() then
            return itemDetails:get().Name or "???"
        else
            return ""
        end
    end)

    local price = Computed(function()
        if itemDetails:get() then
            return itemDetails:get().Price or 0
        else
            return 0
        end
    end)

    local icon = Computed(function()
        if Unwrap(itemDetails) then
            local thumbnailType = if Unwrap(avatarItemType) == Enum.AvatarItemType.Bundle then "BundleThumbnail" else "Asset"
            return `rbxthumb://type={thumbnailType}&id={id:get()}&w=420&h=420`
        else
            return ""
        end
    end)

    if not itemDetails:get() then
        task.spawn(function()
            local result = AvatarEditorService:GetItemDetails(id:get(), Unwrap(avatarItemType))
            itemDetails:set(result)
        end)
    end

    local function EquipItem(itemId: number, assetType: string)
        if equipCallback == nil or equipCallback(itemId, assetType) then
            isEquipped:set(true)
        end
    end

    local function UnequipItem(itemId: number, assetType: string)
        if unequipCallback == nil or unequipCallback(itemId, assetType) then
            isEquipped:set(false)
        end
    end

    local function OnButtonClicked()
        if isOwned:get() then
            if isEquipped:get() then
                UnequipItem(itemDetails:get().Id, itemDetails:get().AssetType)
            else
                EquipItem(itemDetails:get().Id, itemDetails:get().AssetType)
            end
        else
            -- Buy
            if Unwrap(avatarItemType) == Enum.AvatarItemType.Bundle then
                MarketplaceService:PromptBundlePurchase(Players.LocalPlayer, id:get())
            else
                MarketplaceService:PromptPurchase(Players.LocalPlayer, id:get())
            end
        end
    end

    local function OnPurchaseFinished(_, purchaseId: number, wasPurchased: boolean)
        if not itemDetails:get() then
            return
        end

        if tostring(purchaseId) == tostring(id:get()) and wasPurchased then
            local newDetails = itemDetails:get()
            newDetails.Owned = true
            itemDetails:set(newDetails)
        end
    end

    if avatarItemType == Enum.AvatarItemType.Asset then
        MarketplaceService.PromptPurchaseFinished:Connect(OnPurchaseFinished)
    elseif avatarItemType == Enum.AvatarItemType.Bundle then
        MarketplaceService.PromptBundlePurchaseFinished:Connect(OnPurchaseFinished)
    end

    local ui = Background {
        Name = "AvatarShopItemCard",
        AutomaticSize = Enum.AutomaticSize.None,
        Size = UDim2.fromScale(0, 0),
        -- Faces are unclear on completely black backgrounds.
        BackgroundColor3 = ThemeProvider:GetColor("background_3"),

        [Cleanup] = cleanup,

        [Children] = {
            Nest {
                [Children] = {
                    ProductImage {
                        Name = "Icon",
                        LayoutOrder = 1,
                        Image = icon,
                        Size = UDim2.fromScale(1, 1),
                        SizeConstraint = Enum.SizeConstraint.RelativeYY,
                    },

                    Nest {
                        LayoutOrder = 2,
                        Visible = Computed(function()
                            return Unwrap(detailsHidden) ~= true
                        end),

                        [Children] = {
                            Label {
                                Name = "ItemName",
                                LayoutOrder = 1,
                                Text = itemName,
                                TextWrapped = false,
                                FontFace = ThemeProvider:GetFontFace("bold")
                            },

                            IconContainer {
                                LayoutOrder = 2,
                                Icon = Icon {
                                    Image = "rbxassetid://13480760066"
                                },
                                Label = Label { Text = price }
                            },

                            VerticalListLayout { Padding = UDim.new(0, 4) }
                        }
                    },

                    HorizontalListLayout { Padding = UDim.new(0, 12) }
                },
            },

            PrimaryButton {
                Position = UDim2.fromScale(1, 0),
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = Computed(function()
                    local color = if isOwned:get() then ThemeProvider:GetColor("primary") else ThemeProvider:GetColor("accent")
                    return Unwrap(color)
                end),
                Visible = Computed(function()
                    return Unwrap(detailsHidden) ~= true
                end),

                Text = Computed(function()
                    if isOwned:get() then
                        return if isEquipped:get() then "Unequip" else "Equip"
                    else
                        return "Purchase"
                    end
                end),

                [OnEvent "MouseButton1Click"] = OnButtonClicked
            },

            New "UICorner" {
                CornerRadius = UDim.new(0, 14)
            },

            ShorthandPadding { Padding = UDim.new(0, 12) },
        }
    }

    return Hydrate(ui)(StripProps(props, STRIPPED_PROPS))
end

return AvatarItemCard