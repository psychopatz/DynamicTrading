-- ============================================================================
-- Weapon Items Registry for Dynamic Trading
-- If you want some suggestions or have balancing issues, please report them to
-- my discussion page. Happy to adjust prices and stock based on your feedback! :)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3635333613
-- ============================================================================

require "DT/Common/Config"
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    -- The items are grouped by Primary tag and Rarity

    -- [Weapon.Explosive] [Rarity.Common] (1 item)
    { item="Base.Molotov", basePrice=133, tags={"Weapon.Explosive", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },

    -- [Weapon.Explosive] [Rarity.Rare] (18 items)
    { item="Base.Aerosolbomb", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.AerosolbombRemote", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.AerosolbombSensorV1", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.AerosolbombSensorV2", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.AerosolbombSensorV3", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.AerosolbombTriggered", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.PipeBomb", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.PipeBombRemote", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.PipeBombSensorV1", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.PipeBombSensorV2", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.PipeBombSensorV3", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.PipeBombTriggered", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmokeBomb", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmokeBombRemote", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmokeBombSensorV1", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmokeBombSensorV2", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmokeBombSensorV3", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmokeBombTriggered", basePrice=213, tags={"Weapon.Explosive", "Rarity.Rare", "Origin.Vanilla"}, stockRange={min=0, max=1} },
})

print("[DynamicTrading] Explosive Registry Complete")
