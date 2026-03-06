# Project Zomboid Spawn Rate Analysis

## Overview
This document provides spawn rate data extracted from `ProceduralDistributions.lua` to help determine item rarity.

**Total Items with Spawn Data:** 3984

## Spawn Weight Distribution

| Rarity Tier | Spawn Weight Range | Item Count | Percentage |
|-------------|-------------------|------------|------------|
| Ultra Rare  | < 0.1             | 135 | 3.4% |
| Legendary   | 0.1 - 0.5         | 245 | 6.1% |
| Rare        | 0.5 - 2.0         | 706 | 17.7% |
| Uncommon    | 2.0 - 5.0         | 1077 | 27.0% |
| Common      | > 5.0             | 1821 | 45.7% |

---

## Rarest Items (Ultra Rare)

Items with average spawn weight < 0.1:

| Item | Avg Weight | Spawn Locations | Details |
|------|------------|-----------------|---------|
| `HamRadio2` | 0.001 | 4 | ArmyBunkerLockers, ArmyBunkerStorage, CrateElectronics (+1 more) |
| `-- Special
			"ManPackRadio` | 0.001 | 1 | ArmySurplusMisc |
| `HalloweenCandyBucket` | 0.001 | 5 | BedroomDresserChild, BedroomSidetableChild, UniversitySideTable (+2 more) |
| `HollowBook_Kids` | 0.001 | 3 | BedroomDresserChild, BedroomSidetableChild, WardrobeChild |
| `HollowBook_Valuables` | 0.001 | 9 | BedroomDresserClassy, BedroomSidetableClassy, DrugLabMoney (+6 more) |
| `HollowBook_Handgun` | 0.001 | 5 | BedroomDresserRedneck, BedroomSidetableRedneck, DrugLabGuns (+2 more) |
| `HollowBook_Whiskey` | 0.001 | 7 | BedroomDresserRedneck, BedroomSidetableRedneck, OfficeDeskStressed (+4 more) |
| `CookieJar_Bear` | 0.001 | 2 | BedroomSidetableChild, KitchenBreakfast |
| `-- TODO: Sort me!
			"AssaultRifle2` | 0.001 | 1 | ClosetInstruments |
| `CowHide` | 0.001 | 3 | ClosetInstruments, ClosetShelfGeneric, ClosetSportsEquipment |
| `-- TODO: Sort Me!
			"AssaultRifle2` | 0.001 | 2 | ClosetShelfGeneric, ClosetSportsEquipment |
| `-- Story Items
			"CortmanPic` | 0.001 | 1 | CortmanOfficeDesk |
| `-- Special
			"HollowBook` | 0.001 | 3 | DrugShackMisc, LivingRoomShelf, WardrobeGeneric |
| `-- Special
			"HollowBook_Handgun` | 0.001 | 1 | DrugShackWeapons |
| `KeyRing_StinkyFace` | 0.001 | 1 | KitchenRandom |
| `-- Special
			"CookieJar_Bear` | 0.001 | 1 | KitchenRandom |
| `-- Literature (Magazines)
			"ArmorMag3` | 0.001 | 2 | LivingRoomShelfRedneck, LivingRoomSideTableRedneck |
| `-- Special
			"CigarBox_Keepsakes` | 0.001 | 1 | LivingRoomSideTable |
| `-- Keyrings (Personalized)
			"KeyRing_Bass` | 0.001 | 2 | OfficeDeskHome, OfficeDeskHomeClassy |
| `-- Literature
			"ArmorMag7` | 0.001 | 2 | PoliceCaptainDesk, PoliceDesk |
| `-- Special
			"Briefcase_Money` | 0.001 | 1 | PoliceFileBox |
| `Chainmail_SleeveFull_R` | 0.001 | 1 | SafehouseArmor_Late |
| `-- Special
			"ArmorMag7` | 0.001 | 2 | SecurityDesk, SecurityLockers |
| `-- Guns/Ammo
			"AssaultRifle2` | 0.001 | 3 | WardrobeClassy, WardrobeGeneric, WardrobeRedneck |
| `-- Special
			"Bag_MoneyBag` | 0.001 | 1 | WardrobeClassy |
| `Lunchbox2` | 0.003 | 11 | FireDeptLockers, FridgeBreakRoom, FridgeDrugLab (+8 more) |
| `-- Special
			"HollowBook_Prison` | 0.003 | 2 | PrisonCellRandom, PrisonCellRandomClassy |
| `Mov_RedRotaryPhone` | 0.003 | 4 | ClosetInstruments, ClosetShelfGeneric, ClosetSportsEquipment (+1 more) |
| `Mov_WhiteRotaryPhone` | 0.003 | 4 | ClosetInstruments, ClosetShelfGeneric, ClosetSportsEquipment (+1 more) |
| `Shirt_Jockey04` | 0.005 | 3 | BackstageClothingRack, BackstageDresser, BackstageLockers |


## Legendary Items

Items with average spawn weight 0.1 - 0.5:

| Item | Avg Weight | Spawn Locations | Sample Weights |
|------|------------|-----------------|----------------|
| `Glasses_MonocleLeft` | 0.100 | 1 | 0.10 |
| `-- Food/Drink
			"CannedCarrots2` | 0.100 | 1 | 0.10 |
| `-- Army Equipment
			"FlashLight_AngleHead_Army` | 0.100 | 1 | 0.10 |
| `-- Bags/Containers
			"Bag_ProtectiveCaseBulkyHazard` | 0.100 | 1 | 0.10 |
| `DuctTapeBox` | 0.100 | 1 | 0.10 |
| `Vest_BulletDesert` | 0.100 | 1 | 0.10 |
| `Vest_BulletOliveDrab` | 0.100 | 1 | 0.10 |
| `Vest_Trucker` | 0.100 | 4 | 0.10, 0.10, 0.10 |
| `Hat_Sheriff` | 0.100 | 2 | 0.10, 0.10 |
| `ScratchTicket_Winner` | 0.100 | 2 | 0.10, 0.10 |
| `-- Watches
			"WristWatch_Left_ClassicBlack` | 0.100 | 9 | 0.10, 0.10, 0.10 |
| `-- Special
			"Flask` | 0.100 | 2 | 0.10, 0.10 |
| `KeyRing_WestMaple` | 0.100 | 5 | 0.10, 0.10, 0.10 |
| `WineAgedEmpty` | 0.100 | 2 | 0.10, 0.10 |
| `-- Keys/Keyrings
			"KeyRing_CarDealer` | 0.100 | 1 | 0.10 |
| `KeyRing_CarDealer` | 0.100 | 1 | 0.10 |
| `-- Snacks
			"CandyNovapops` | 0.100 | 2 | 0.10, 0.10 |
| `-- Special
			"TrophyBronze` | 0.100 | 4 | 0.10, 0.10, 0.10 |
| `-- Special
			"LighterDisposable` | 0.100 | 1 | 0.10 |
| `ClosedUmbrellaBlack` | 0.100 | 5 | 0.10, 0.10, 0.10 |
| `ClosedUmbrellaBlue` | 0.100 | 8 | 0.10, 0.10, 0.10 |
| `ClosedUmbrellaRed` | 0.100 | 8 | 0.10, 0.10, 0.10 |
| `ClosedUmbrellaWhite` | 0.100 | 8 | 0.10, 0.10, 0.10 |
| `Necklace_Teeth` | 0.100 | 1 | 0.10 |
| `Kneepad_Left` | 0.100 | 1 | 0.10 |
| `-- Misc.
			"Cashbox` | 0.100 | 2 | 0.10, 0.10 |
| `-- Knives
			"KnifePocket` | 0.100 | 1 | 0.10 |
| `-- Bags/Containers
			"Bag_ToolBag` | 0.100 | 1 | 0.10 |
| `KeyRing_Forged_Gold` | 0.100 | 1 | 0.10 |
| `-- Misc.
			"ButterKnife_Gold` | 0.100 | 1 | 0.10 |


## Common Items

Items with highest spawn weights (> 10):

| Item | Avg Weight | Spawn Locations |
|------|------------|-----------------|
| `Mov_AntiqueStove` | 200.00 | 1 |
| `Mov_BlackBBQ` | 200.00 | 2 |
| `Mov_BlueComfyChair` | 200.00 | 1 |
| `Mov_BlueRattanChair` | 200.00 | 1 |
| `Mov_BrownComfyChair` | 200.00 | 1 |
| `Mov_ChestFreezer` | 200.00 | 1 |
| `Mov_FitnessContraption` | 200.00 | 1 |
| `Mov_GreenComfyChair` | 200.00 | 1 |
| `Mov_GreenOven` | 200.00 | 1 |
| `Mov_GreyComfyChair` | 200.00 | 1 |
| `Mov_GreyOven` | 200.00 | 1 |
| `Mov_LightRoundTable` | 200.00 | 1 |
| `Mov_ModernOven` | 200.00 | 1 |
| `Mov_OakRoundTable` | 200.00 | 1 |
| `Mov_OrangeModernChair` | 200.00 | 1 |
| `Mov_OrangeFuton` | 200.00 | 1 |
| `Mov_PurpleRattanChair` | 200.00 | 1 |
| `Mov_RedBBQ` | 200.00 | 2 |
| `Mov_RedOven` | 200.00 | 1 |
| `Mov_RoundTable` | 200.00 | 1 |
| `Mov_SkeletonDisplay` | 200.00 | 1 |
| `TvBlack` | 200.00 | 1 |
| `TvWideScreen` | 200.00 | 1 |
| `Mov_WhiteComfyChair` | 200.00 | 1 |
| `Mov_YellowModernChair` | 200.00 | 1 |
| `-- Firearms
				"Revolver_Long` | 200.00 | 1 |
| `Shirt_NoSleeves_Crafted_Burlap` | 200.00 | 1 |
| `Shoes_RagWrap` | 200.00 | 1 |
| `-- Photography
			"CameraFilm` | 200.00 | 1 |
| `-- Paperwork
			"Paperwork` | 200.00 | 2 |


## Usage Guide

### Integrating Spawn Data with Item Properties

To determine comprehensive rarity, combine spawn weight with item properties:

1. **Calculate Weighted Rarity Score**
   ```python
   def calculate_rarity_score(item):
       # Get spawn weight (lower = rarer)
       spawn_weight = get_spawn_weight(item)
       spawn_score = max(0, 100 - spawn_weight * 10)
       
       # Get property scores
       damage_score = item.MaxDamage * 50 if hasattr(item, 'MaxDamage') else 0
       durability_score = item.ConditionMax * 2
       
       # Check special tags
       tag_score = 0
       if 'military' in item.tags: tag_score += 30
       if 'police' in item.tags: tag_score += 20
       if 'tactical' in item.tags: tag_score += 25
       
       # Calculate final score (0-100 scale)
       final_score = (spawn_score * 0.6 + damage_score * 0.2 + 
                     durability_score * 0.1 + tag_score * 0.1)
       
       return min(100, final_score)
   ```

2. **Rarity Tier Assignment**
   - **Ultra Rare** (90-100): Spawn weight < 0.1, high stats, special tags
   - **Legendary** (75-89): Spawn weight 0.1-0.5, exceptional stats
   - **Rare** (60-74): Spawn weight 0.5-2.0, good stats
   - **Uncommon** (40-59): Spawn weight 2.0-5.0, moderate stats
   - **Common** (0-39): Spawn weight > 5.0, basic stats

### Example Calculations

**Military Rifle (e.g., AssaultRifle)**
- Spawn weight: 0.15 → spawn_score = 98.5
- MaxDamage: 1.8 → damage_score = 90
- ConditionMax: 10 → durability_score = 20
- Tags: military → tag_score = 30
- **Final Score: 88.5 (Legendary)**

**Kitchen Knife**
- Spawn weight: 8.0 → spawn_score = 20
- MaxDamage: 0.5 → damage_score = 25
- ConditionMax: 5 → durability_score = 10
- Tags: none → tag_score = 0
- **Final Score: 18.0 (Common)**

---

## Data Source
- File: `media/lua/server/Items/ProceduralDistributions.lua`
- Build: 42
- Last Updated: Generated from game installation
