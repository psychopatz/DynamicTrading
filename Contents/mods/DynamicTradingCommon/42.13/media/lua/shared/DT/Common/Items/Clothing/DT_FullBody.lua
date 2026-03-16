-- ============================================================================
-- Clothing Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Clothing.FullBody] [Rarity.Rare] (12 items)
    { item="Base.Boilersuit", basePrice=612, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_BlueRed", basePrice=612, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_Flying", basePrice=614, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_Prisoner", basePrice=608, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_PrisonerKhaki", basePrice=606, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_SWAT", basePrice=1067, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.Tactical"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_Yellow", basePrice=612, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated"}, stockRange={min=0, max=12} },
    { item="Base.LongJohns", basePrice=602, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.LongJohns_Crafted_Burlap", basePrice=604, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.LongJohns_Crafted_Cotton", basePrice=602, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.SpiffoSuit", basePrice=610, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.WeddingDress", basePrice=599, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] FullBody Registry Complete")
