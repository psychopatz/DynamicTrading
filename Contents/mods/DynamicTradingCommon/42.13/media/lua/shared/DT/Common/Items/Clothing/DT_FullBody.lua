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
    { item="Base.Boilersuit", basePrice=4, tags={"Clothing.FullBody", "Rarity.Rare", "Clothing.Insulated"}, stockRange={min=0, max=6} },
    { item="Base.Boilersuit_BlueRed", basePrice=4, tags={"Clothing.FullBody", "Rarity.Rare", "Clothing.Insulated"}, stockRange={min=0, max=6} },
    { item="Base.Boilersuit_Flying", basePrice=5, tags={"Clothing.FullBody", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
    { item="Base.Boilersuit_Prisoner", basePrice=3, tags={"Clothing.FullBody", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Boilersuit_PrisonerKhaki", basePrice=3, tags={"Clothing.FullBody", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Boilersuit_SWAT", basePrice=4, tags={"Clothing.FullBody", "Rarity.Rare", "Clothing.Insulated", "Clothing.Tactical"}, stockRange={min=0, max=6} },
    { item="Base.Boilersuit_Yellow", basePrice=4, tags={"Clothing.FullBody", "Rarity.Rare", "Clothing.Insulated"}, stockRange={min=0, max=6} },
    { item="Base.LongJohns", basePrice=10, tags={"Clothing.FullBody", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LongJohns_Crafted_Burlap", basePrice=16, tags={"Clothing.FullBody", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.LongJohns_Crafted_Cotton", basePrice=10, tags={"Clothing.FullBody", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.SpiffoSuit", basePrice=2, tags={"Clothing.FullBody", "Rarity.Rare", "Clothing.Insulated", "Clothing.WindResistant"}, stockRange={min=0, max=6} },
    { item="Base.WeddingDress", basePrice=1, tags={"Clothing.FullBody", "Rarity.Rare"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] FullBody Registry Complete")
