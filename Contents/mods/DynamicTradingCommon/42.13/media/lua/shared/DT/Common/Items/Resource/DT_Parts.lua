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

    -- [Resource.Parts] [Rarity.Rare] (28 items)
    { item="Base.ClawhammerHead", basePrice=68, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.CrudeShortSwordBlade", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CrudeShortSwordBlade_NoTang", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CrudeSwordBlade", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.CrudeSwordBlade_Broken", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CrudeSwordBlade_Broken_NoTang", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CrudeSwordBlade_NoTang", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.FireAxeHead", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.HandAxeHead", basePrice=3, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.HatchetHead_Bone", basePrice=3, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.HuntingKnifeBlade", basePrice=2, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.KitchenKnifeBlade", basePrice=3, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.LargeKnifeBlade", basePrice=2, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.MaceHead", basePrice=2, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.MacheteBlade", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.MacheteBlade_NoTang", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.OldAxeHead", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.ShortSwordBlade", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.ShortSwordBlade_NoTang", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.SledgehammerHead", basePrice=6, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SpearHead", basePrice=3, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.StoneAxeHead", basePrice=2, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneMaceHead", basePrice=2, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.SwordBlade", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SwordBlade_Broken", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.SwordBlade_Broken_NoTang", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.SwordBlade_NoTang", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.WoodAxeHead", basePrice=1, tags={"Resource.Parts", "Rarity.Rare", "Resource.Craftable"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Parts Registry Complete")
