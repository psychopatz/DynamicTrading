-- ============================================================================
-- Tool Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Tool.Crafting] [Rarity.Rare] (8 items)
    { item="Base.BallPeenHammerHead", basePrice=572, tags={"Tool.Crafting", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=7} },
    { item="Base.ClubHammerHead", basePrice=571, tags={"Tool.Crafting", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=2} },
    { item="Base.CrudeSaw", basePrice=583, tags={"Tool.Crafting", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.GardenSaw", basePrice=596, tags={"Tool.Crafting", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.OldDrill", basePrice=573, tags={"Tool.Crafting", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=2} },
    { item="Base.Saw", basePrice=596, tags={"Tool.Crafting", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.SmallSaw", basePrice=591, tags={"Tool.Crafting", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=3} },
    { item="Base.SmithingHammerHead", basePrice=572, tags={"Tool.Crafting", "Rarity.Rare", "Origin.Vanilla", "Tool.Fragile"}, stockRange={min=0, max=7} },
})

print("[DynamicTrading] Crafting Registry Complete")
