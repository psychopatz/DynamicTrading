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

    -- [Resource.Fuel.Gas] [Rarity.Rare] (11 items)
    { item="Base.BigGasTank1", basePrice=1980, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.BigGasTank2", basePrice=1978, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.BigGasTank3", basePrice=1980, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.NormalGasTank1", basePrice=1980, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.NormalGasTank2", basePrice=1979, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.NormalGasTank3", basePrice=1980, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Propane_Refill", basePrice=2015, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=2} },
    { item="Base.PropaneTank", basePrice=2065, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=1} },
    { item="Base.SmallGasTank1", basePrice=1981, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmallGasTank2", basePrice=1980, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmallGasTank3", basePrice=1981, tags={"Resource.Fuel.Gas", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },

    -- [Resource.Fuel.Liquid] [Rarity.Rare] (2 items)
    { item="Base.BBQStarterFluid", basePrice=1978, tags={"Resource.Fuel.Liquid", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=8} },
    { item="Base.LighterFluid", basePrice=1978, tags={"Resource.Fuel.Liquid", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=14} },

    -- [Resource.Fuel.Solid] [Rarity.Rare] (3 items)
    { item="Base.Charcoal", basePrice=2012, tags={"Resource.Fuel.Solid", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.CharcoalCrafted", basePrice=2012, tags={"Resource.Fuel.Solid", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=6} },
    { item="Base.FirewoodBundle", basePrice=2009, tags={"Resource.Fuel.Solid", "Rarity.Rare", "Origin.Vanilla", "Resource.Craftable"}, stockRange={min=0, max=2} },
})

print("[DynamicTrading] Fuel Registry Complete")
