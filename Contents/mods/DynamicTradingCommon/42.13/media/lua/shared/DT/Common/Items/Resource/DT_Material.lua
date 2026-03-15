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

    -- [Resource.Material] [Rarity.Rare] (46 items)
    { item="Base.BakingSoda", basePrice=45, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.BathTowel", basePrice=45, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.BlowTorch", basePrice=14, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Candle", basePrice=68, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.CandleLit", basePrice=68, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.CigaretteRollingPapers", basePrice=136, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.CorrectionFluid", basePrice=68, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.DishCloth", basePrice=45, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.Garbagebag_box", basePrice=14, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.GravyMix", basePrice=136, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.Hairgel", basePrice=27, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.Hairspray2", basePrice=17, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.InsectRepellent", basePrice=17, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.Lighter", basePrice=136, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.LighterBBQ", basePrice=45, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.LighterDisposable", basePrice=136, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.Lipstick", basePrice=68, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.MagnesiumFirestarter", basePrice=136, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.MakeupEyeshadow", basePrice=136, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.MakeupFoundation", basePrice=68, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.Matchbox", basePrice=45, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.Matches", basePrice=136, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.PaintBlack", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintBlue", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintBrown", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintCyan", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintGreen", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintGrey", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintLightBlue", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintLightBrown", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintOrange", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintPink", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintPurple", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintRed", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintTurquoise", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintWhite", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PaintYellow", basePrice=3, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=10} },
    { item="Base.PancakeMix", basePrice=136, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.PaperNapkins2", basePrice=64, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.RatPoison", basePrice=14, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.RespiratorFilters", basePrice=45, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.RespiratorFiltersRecharged", basePrice=45, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=30} },
    { item="Base.Soap2", basePrice=68, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.SprayPaint", basePrice=14, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=20} },
    { item="Base.WaterPurificationTablets", basePrice=68, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
    { item="Base.Yeast", basePrice=68, tags={"Resource.Material", "Rarity.Rare"}, stockRange={min=0, max=50} },
})

print("[DynamicTrading] Material Registry Complete")
