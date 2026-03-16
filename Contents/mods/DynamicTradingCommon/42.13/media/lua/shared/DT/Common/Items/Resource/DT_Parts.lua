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
    { item="Base.ClawhammerHead", basePrice=528, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.CrudeShortSwordBlade", basePrice=513, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.CrudeShortSwordBlade_NoTang", basePrice=513, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.CrudeSwordBlade", basePrice=513, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.CrudeSwordBlade_Broken", basePrice=154, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.CrudeSwordBlade_Broken_NoTang", basePrice=154, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.CrudeSwordBlade_NoTang", basePrice=513, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.FireAxeHead", basePrice=527, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.HandAxeHead", basePrice=528, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.HatchetHead_Bone", basePrice=507, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=5} },
    { item="Base.HuntingKnifeBlade", basePrice=528, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.KitchenKnifeBlade", basePrice=528, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.LargeKnifeBlade", basePrice=513, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.MaceHead", basePrice=513, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.MacheteBlade", basePrice=527, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.MacheteBlade_NoTang", basePrice=527, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.OldAxeHead", basePrice=513, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.ShortSwordBlade", basePrice=527, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.ShortSwordBlade_NoTang", basePrice=527, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SledgehammerHead", basePrice=526, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SpearHead", basePrice=528, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=4} },
    { item="Base.StoneAxeHead", basePrice=522, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.StoneMaceHead", basePrice=522, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=3} },
    { item="Base.SwordBlade", basePrice=527, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SwordBlade_Broken", basePrice=158, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SwordBlade_Broken_NoTang", basePrice=158, tags={"Resource.Parts", "Rarity.Rare", "Quality.Waste", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
    { item="Base.SwordBlade_NoTang", basePrice=527, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.WoodAxeHead", basePrice=527, tags={"Resource.Parts", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Parts Registry Complete")
