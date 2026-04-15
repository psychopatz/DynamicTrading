-- ============================================================================
-- Resource Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Resource.Material.Paper] [Rarity.Rare] (9 items)
    { item="Base.Paperclip", basePrice=59, tags={"Resource.Material.Paper", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=30} },
    { item="Base.PaperclipBox", basePrice=112, tags={"Resource.Material.Paper", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=8} },
    { item="Base.Wallpaper_BeigeStripe", basePrice=76, tags={"Resource.Material.Paper", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Wallpaper_BlackFloral", basePrice=76, tags={"Resource.Material.Paper", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Wallpaper_BlueStripe", basePrice=76, tags={"Resource.Material.Paper", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Wallpaper_GreenDiamond", basePrice=214, tags={"Resource.Material.Paper", "Rarity.Rare", "Quality.Luxury", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Wallpaper_GreenFloral", basePrice=76, tags={"Resource.Material.Paper", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Wallpaper_PinkChevron", basePrice=76, tags={"Resource.Material.Paper", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.Wallpaper_PinkFloral", basePrice=76, tags={"Resource.Material.Paper", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Paper Registry Complete")
