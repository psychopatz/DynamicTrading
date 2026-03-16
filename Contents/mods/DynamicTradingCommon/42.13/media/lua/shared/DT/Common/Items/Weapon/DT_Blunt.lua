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
    { item="Base.BallPeenHammer", basePrice=528, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BallPeenHammerForged", basePrice=528, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BaseballBat", basePrice=569, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Broken", basePrice=153, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.BaseballBat_Broken_Nails", basePrice=155, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.BaseballBat_Can", basePrice=584, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Crafted", basePrice=569, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_GardenForkHead", basePrice=564, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Metal", basePrice=583, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Metal_Bolts", basePrice=586, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Nails", basePrice=571, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_RailSpike", basePrice=565, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_RakeHead", basePrice=533, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_ScrapSheet", basePrice=180, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BaseballBat_Spiked", basePrice=565, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BlockMace", basePrice=531, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BoneClub", basePrice=512, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.BoneClub_Spiked", basePrice=531, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.BucketMace_Metal", basePrice=578, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.BucketMace_Wood", basePrice=578, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.ClubHammer", basePrice=528, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.ClubHammerForged", basePrice=528, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Crowbar", basePrice=552, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.CrowbarForged", basePrice=552, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Golfclub", basePrice=549, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Hammer", basePrice=528, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HammerForged", basePrice=528, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.HammerStone", basePrice=514, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.JawboneBovide_Club", basePrice=527, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.KettleMace_Metal", basePrice=591, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.KettleMace_Wood", basePrice=591, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.LargeBoneClub", basePrice=514, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LargeBoneClub_Spiked", basePrice=533, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LeadPipe", basePrice=566, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.LongMace", basePrice=574, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LongMace_Stone", basePrice=569, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.LongSpikedClub", basePrice=544, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.Mace", basePrice=552, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Mace_Stone", basePrice=550, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MetalPipe", basePrice=544, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.MetalPipe_Broken", basePrice=160, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Quality.Waste", "Origin.Vanilla"}, stockRange={min=0, max=7} },
    { item="Base.MetalPipe_Railspike", basePrice=544, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Nightstick", basePrice=564, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.PipeWrench", basePrice=523, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat", basePrice=528, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_Can", basePrice=544, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.ShortBat_Nails", basePrice=532, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_RailSpike", basePrice=544, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.ShortBat_RakeHead", basePrice=524, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Sledgehammer", basePrice=536, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.Sledgehammer2", basePrice=536, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SledgehammerForged", basePrice=536, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=1} },
    { item="Base.SmithingHammer", basePrice=528, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.SpikedShortBat", basePrice=542, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=3} },
    { item="Base.WoodenMallet", basePrice=523, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
    { item="Base.Wrench", basePrice=522, tags={"Weapon.Melee.Blunt", "Rarity.Common", "Origin.Vanilla"}, stockRange={min=0, max=6} },
})

print("[DynamicTrading] Blunt Registry Complete")
