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

    -- [Clothing.Underwear.Bottom] [Rarity.Rare] (25 items)
    { item="Base.Boxers_Hearts", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Boxers_RedStripes", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Boxers_Silk_Black", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Boxers_Silk_Red", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Boxers_White", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_AnimalPrints", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_Burlap", basePrice=600, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_Denim", basePrice=600, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_Garbage", basePrice=598, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_Hide", basePrice=600, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_Rag", basePrice=598, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_SmallTrunks_Black", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_SmallTrunks_Blue", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_SmallTrunks_Red", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_SmallTrunks_WhiteTINT", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_Tarp", basePrice=600, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Briefs_White", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.FrillyUnderpants_Black", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.FrillyUnderpants_Pink", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.FrillyUnderpants_Red", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Underpants_AnimalPrint", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Underpants_Black", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Underpants_Hide", basePrice=600, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Underpants_RedSpots", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Underpants_White", basePrice=596, tags={"Clothing.Underwear.Bottom", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Underwear.General] [Rarity.Rare] (9 items)
    { item="Base.Bikini_Pattern01", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bikini_TINT", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.BunnySuitBlack", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.BunnySuitPink", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Swimsuit_TINT", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.SwimTrunks_Blue", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.SwimTrunks_Green", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.SwimTrunks_Red", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.SwimTrunks_Yellow", basePrice=596, tags={"Clothing.Underwear.General", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },

    -- [Clothing.Underwear.Top] [Rarity.Rare] (30 items)
    { item="Base.BoobTube", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.BoobTubeSmall", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Strapless_AnimalPrint", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Strapless_Black", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Strapless_FrillyBlack", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Strapless_FrillyPink", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Strapless_FrillyRed", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Strapless_Hide", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Strapless_RedSpots", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Strapless_White", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Straps_AnimalPrint", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Straps_Black", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Straps_FrillyBlack", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Straps_FrillyPink", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Straps_FrillyRed", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Straps_Hide", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Bra_Straps_White", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Corset", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Corset_Black", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Corset_Medical", basePrice=667, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla", "Theme.Clinical", "Clothing.Medical"}, stockRange={min=0, max=9} },
    { item="Base.Corset_Red", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.Garter", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.StockingsBlack", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.StockingsBlackSemiTrans", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.StockingsBlackTrans", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.StockingsWhite", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.TightsBlack", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.TightsBlackSemiTrans", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.TightsBlackTrans", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
    { item="Base.TightsFishnets", basePrice=596, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=12} },
})

print("[DynamicTrading] Underwear Registry Complete")
