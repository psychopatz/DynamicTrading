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
    { item="Base.Boxers_Hearts", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Boxers_RedStripes", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Boxers_Silk_Black", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Boxers_Silk_Red", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Boxers_White", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_AnimalPrints", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_Burlap", basePrice=11, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_Denim", basePrice=11, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_Garbage", basePrice=5, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_Hide", basePrice=11, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_Rag", basePrice=5, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_SmallTrunks_Black", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_SmallTrunks_Blue", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_SmallTrunks_Red", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_SmallTrunks_WhiteTINT", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_Tarp", basePrice=11, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Briefs_White", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.FrillyUnderpants_Black", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.FrillyUnderpants_Pink", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.FrillyUnderpants_Red", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Underpants_AnimalPrint", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Underpants_Black", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Underpants_Hide", basePrice=11, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Underpants_RedSpots", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Underpants_White", basePrice=1, tags={"Clothing.Underwear.Bottom", "Rarity.Rare"}, stockRange={min=0, max=10} },

    -- [Clothing.Underwear.General] [Rarity.Rare] (9 items)
    { item="Base.Bikini_Pattern01", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bikini_TINT", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BunnySuitBlack", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.BunnySuitPink", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Swimsuit_TINT", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SwimTrunks_Blue", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SwimTrunks_Green", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SwimTrunks_Red", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.SwimTrunks_Yellow", basePrice=1, tags={"Clothing.Underwear.General", "Rarity.Rare"}, stockRange={min=0, max=10} },

    -- [Clothing.Underwear.Top] [Rarity.Rare] (30 items)
    { item="Base.BoobTube", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.BoobTubeSmall", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=6} },
    { item="Base.Bra_Strapless_AnimalPrint", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Strapless_Black", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Strapless_FrillyBlack", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Strapless_FrillyPink", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Strapless_FrillyRed", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Strapless_Hide", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Strapless_RedSpots", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Strapless_White", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Straps_AnimalPrint", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Straps_Black", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Straps_FrillyBlack", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Straps_FrillyPink", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Straps_FrillyRed", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Straps_Hide", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Bra_Straps_White", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Corset", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Corset_Black", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Corset_Medical", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare", "Origin.Clinical", "Clothing.Medical"}, stockRange={min=0, max=10} },
    { item="Base.Corset_Red", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.Garter", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.StockingsBlack", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.StockingsBlackSemiTrans", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.StockingsBlackTrans", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.StockingsWhite", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.TightsBlack", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.TightsBlackSemiTrans", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.TightsBlackTrans", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.TightsFishnets", basePrice=1, tags={"Clothing.Underwear.Top", "Rarity.Rare"}, stockRange={min=0, max=10} },
})

print("[DynamicTrading] Underwear Registry Complete")
