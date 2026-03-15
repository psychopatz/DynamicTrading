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

    -- [Tool.Crafting] [Rarity.Rare] (14 items)
    { item="Base.BallPeenHammerHead", basePrice=68, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.CircularSawblade", basePrice=17, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=2} },
    { item="Base.CircularSawblade_Half", basePrice=17, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.ClawhammerHead", basePrice=68, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.ClubHammerHead", basePrice=17, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=2} },
    { item="Base.CrudeSaw", basePrice=17, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.GardenSaw", basePrice=34, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.HacksawBlade", basePrice=68, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.OldDrill", basePrice=17, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.Saw", basePrice=34, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.SledgehammerHead", basePrice=6, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=1} },
    { item="Base.SmallSaw", basePrice=49, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=4} },
    { item="Base.SmallSawblade", basePrice=68, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=6} },
    { item="Base.SmithingHammerHead", basePrice=68, tags={"Tool.Crafting", "Rarity.Rare", "Tool.Fragile"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Crafting Registry Complete")
