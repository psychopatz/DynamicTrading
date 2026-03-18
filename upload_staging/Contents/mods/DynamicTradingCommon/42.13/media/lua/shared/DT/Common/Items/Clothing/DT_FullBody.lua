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
    { item="Base.Boilersuit", basePrice=51, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_BlueRed", basePrice=51, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_Flying", basePrice=53, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_Prisoner", basePrice=46, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_PrisonerKhaki", basePrice=45, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_SWAT", basePrice=74, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.Tactical"}, stockRange={min=0, max=12} },
    { item="Base.Boilersuit_Yellow", basePrice=51, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated"}, stockRange={min=0, max=12} },
    { item="Base.LongJohns", basePrice=41, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.LongJohns_Crafted_Burlap", basePrice=43, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.LongJohns_Crafted_Cotton", basePrice=41, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.SpiffoSuit", basePrice=49, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=12} },
    { item="Base.WeddingDress", basePrice=38, tags={"Clothing.FullBody", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] FullBody Registry Complete")
