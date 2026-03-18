-- ============================================================================
-- Container Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Container.Stash.Book] [Rarity.Rare] (6 items)
    { item="Base.HollowBook", basePrice=72, tags={"Container.Stash.Book", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Handgun", basePrice=72, tags={"Container.Stash.Book", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Kids", basePrice=72, tags={"Container.Stash.Book", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Prison", basePrice=72, tags={"Container.Stash.Book", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Valuables", basePrice=72, tags={"Container.Stash.Book", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.HollowBook_Whiskey", basePrice=72, tags={"Container.Stash.Book", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },

    -- [Container.Stash.Case] [Rarity.Rare] (73 items)
    { item="Base.Cashbox", basePrice=145, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CigarBox", basePrice=145, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CigarBox_Gaming", basePrice=145, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CigarBox_Keepsakes", basePrice=145, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CigarBox_Kids", basePrice=145, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.CookieJar", basePrice=144, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.CookieJar_Bear", basePrice=144, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.DiceBag", basePrice=121, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Low"}, stockRange={min=0, max=11} },
    { item="Base.FirstAidKit", basePrice=156, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.FirstAidKit_Camping", basePrice=174, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Theme.Survival", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.FirstAidKit_Camping_New", basePrice=174, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Theme.Survival", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.FirstAidKit_Military", basePrice=200, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Theme.Militia", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.FirstAidKit_New", basePrice=156, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.FirstAidKit_NewPro", basePrice=156, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Flightcase", basePrice=173, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.GemBag", basePrice=140, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=11} },
    { item="Base.Guitarcase", basePrice=162, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.HalloweenCandyBucket", basePrice=145, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Hatbox", basePrice=139, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.HollowFancyBook", basePrice=72, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.Humidor", basePrice=144, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.JewelleryBox", basePrice=144, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.JewelleryBox_Fancy", basePrice=144, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Lunchbox", basePrice=156, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Lunchbox2", basePrice=156, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.MakeupCase_Professional", basePrice=156, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.PaperBag", basePrice=146, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=11} },
    { item="Base.Parcel_ExtraLarge", basePrice=177, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High"}, stockRange={min=0, max=2} },
    { item="Base.Parcel_ExtraSmall", basePrice=67, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.Parcel_Large", basePrice=119, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Parcel_Medium", basePrice=90, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low"}, stockRange={min=0, max=4} },
    { item="Base.Parcel_Small", basePrice=72, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.PencilCase", basePrice=139, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.PencilCase_Gaming", basePrice=139, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.PhotoAlbum", basePrice=91, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low"}, stockRange={min=0, max=6} },
    { item="Base.PhotoAlbum_Old", basePrice=91, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low"}, stockRange={min=0, max=6} },
    { item="Base.PistolCase1", basePrice=157, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.PistolCase2", basePrice=157, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.PistolCase3", basePrice=157, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Present_ExtraLarge", basePrice=177, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High"}, stockRange={min=0, max=2} },
    { item="Base.Present_ExtraSmall", basePrice=67, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.Present_Large", basePrice=119, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Present_Medium", basePrice=90, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low"}, stockRange={min=0, max=4} },
    { item="Base.Present_Small", basePrice=72, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_ExtraLarge", basePrice=177, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.High"}, stockRange={min=0, max=2} },
    { item="Base.ProduceBox_ExtraSmall", basePrice=67, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_Large", basePrice=119, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_Medium", basePrice=90, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low"}, stockRange={min=0, max=4} },
    { item="Base.ProduceBox_Small", basePrice=72, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=4} },
    { item="Base.RevolverCase1", basePrice=157, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.RevolverCase2", basePrice=157, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.RevolverCase3", basePrice=157, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.RifleCase1", basePrice=173, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.RifleCase2", basePrice=173, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.RifleCase3", basePrice=173, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.RifleCase4", basePrice=173, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.SeedBag", basePrice=140, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=11} },
    { item="Base.SewingKit", basePrice=144, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Shoebox", basePrice=139, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.ShotgunCase1", basePrice=173, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.ShotgunCase2", basePrice=173, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.Suitcase", basePrice=223, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Medium", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Tacklebox", basePrice=167, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.TakeoutBox_Chinese", basePrice=145, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.TakeoutBox_Styrofoam", basePrice=145, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Toolbox", basePrice=178, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Toolbox_Farming", basePrice=178, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Toolbox_Fishing", basePrice=178, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Toolbox_Gardening", basePrice=178, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=2} },
    { item="Base.Toolbox_Wooden", basePrice=167, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=4} },
    { item="Base.ToolRoll_Fabric", basePrice=157, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.ToolRoll_Leather", basePrice=157, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Low", "Container.WeightReduction.Medium"}, stockRange={min=0, max=6} },
    { item="Base.Wallet_Hide", basePrice=68, tags={"Container.Stash.Case", "Rarity.Rare", "Origin.Vanilla", "Container.Capacity.Tiny"}, stockRange={min=0, max=11} },
})

print("[DynamicTrading] Stash Registry Complete")
