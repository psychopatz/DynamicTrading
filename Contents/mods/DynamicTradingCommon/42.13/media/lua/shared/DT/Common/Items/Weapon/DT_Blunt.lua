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

    -- [Weapon.Melee.Blunt] [Rarity.Common] (56 items)
    { item="Base.BallPeenHammer", basePrice=56, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BallPeenHammerForged", basePrice=56, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BaseballBat", basePrice=97, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Broken", basePrice=11, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.BaseballBat_Broken_Nails", basePrice=13, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.BaseballBat_Can", basePrice=112, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Crafted", basePrice=97, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_GardenForkHead", basePrice=92, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Metal", basePrice=111, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Metal_Bolts", basePrice=114, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Nails", basePrice=99, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_RailSpike", basePrice=93, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_RakeHead", basePrice=61, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_ScrapSheet", basePrice=38, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Spiked", basePrice=93, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BlockMace", basePrice=59, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BoneClub", basePrice=40, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BoneClub_Spiked", basePrice=59, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BucketMace_Metal", basePrice=106, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.BucketMace_Wood", basePrice=106, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.ClubHammer", basePrice=56, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.ClubHammerForged", basePrice=56, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Crowbar", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.CrowbarForged", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Golfclub", basePrice=77, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Hammer", basePrice=56, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HammerForged", basePrice=56, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HammerStone", basePrice=42, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.JawboneBovide_Club", basePrice=55, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.KettleMace_Metal", basePrice=119, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.KettleMace_Wood", basePrice=119, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.LargeBoneClub", basePrice=42, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LargeBoneClub_Spiked", basePrice=61, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LeadPipe", basePrice=94, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LongMace", basePrice=102, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LongMace_Stone", basePrice=97, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LongSpikedClub", basePrice=72, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Mace", basePrice=80, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Mace_Stone", basePrice=79, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MetalPipe", basePrice=72, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MetalPipe_Broken", basePrice=19, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.MetalPipe_Railspike", basePrice=72, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Nightstick", basePrice=92, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.PipeWrench", basePrice=51, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat", basePrice=56, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_Can", basePrice=72, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.ShortBat_Nails", basePrice=60, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_RailSpike", basePrice=72, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_RakeHead", basePrice=52, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Sledgehammer", basePrice=64, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Sledgehammer2", basePrice=64, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SledgehammerForged", basePrice=64, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmithingHammer", basePrice=56, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.SpikedShortBat", basePrice=70, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.WoodenMallet", basePrice=51, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Wrench", basePrice=50, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Blunt Registry Complete")
