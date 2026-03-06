# Project Zomboid Item Script Parameters Reference

## Overview
This document catalogs all script parameters found in Project Zomboid's item definitions, extracted from vanilla game files in Build 42.

**Statistics:**
- Total unique properties: 372
- Boolean flags: 80
- Numeric properties: 158
- String properties: 134

---

## Boolean Flags

Boolean flags control specific behaviors or attributes of items. They are set to either `true` or `false`.

| Property | Usage Count | Purpose | Example Item |
|----------|------------|---------|--------------|
| `CanHaveHoles` | 576 | Controls canhaveholes | Hat_BunnyEarsBlack |
| `KnockBackOnNoDeath` | 356 | Knockback effect on surviving enemies | SpadeHead |
| `SplatBloodOnNoDeath` | 332 | Splatter blood even if enemy survives | SpadeHead |
| `IsCookable` | 261 | Can be cooked | Saucepan |
| `hidden` | 198 | Controls hidden | F_Hair_Stubble |
| `DamageMakeHole` | 193 | Can penetrate and create holes | SpadeHead |
| `Cosmetic` | 173 | Controls cosmetic | WristWatch_Right_ClassicBlack |
| `WorldRender` | 171 | Controls worldrender | F_Hair_Stubble |
| `TwoHandWeapon` | 159 | Requires both hands to wield | FISH_DEV_ITEM |
| `UseWhileEquipped` | 153 | Controls usewhileequipped | WalkieTalkie1 |
| `GoodHot` | 148 | Controls goodhot | TestHotDrink |
| `Packaged` | 144 | Controls packaged | Vinegar2 |
| `BadInMicrowave` | 115 | Controls badinmicrowave | SugarBeetPulpPot |
| `Spice` | 111 | Controls spice | Vinegar2 |
| `MechanicsItem` | 103 | Controls mechanicsitem | CarBattery1 |
| `CantEat` | 97 | Controls canteat | AnimalMilkPowder |
| `DangerousUncooked` | 81 | Harmful if eaten raw | Bacon |
| `RequiresEquippedBothHands` | 69 | Controls requiresequippedbothhands | JawboneBovide_Morningstar |
| `IsAimedHandWeapon` | 67 | Controls isaimedhandweapon | DoubleBarrelShotgun |
| `BadCold` | 61 | Controls badcold | Bacon |
| `SurvivalGear` | 59 | Controls survivalgear | FISH_DEV_ITEM |
| `cantBeConsolided` | 53 | Controls cantbeconsolided | SheepElectricShears |
| `CantBeFrozen` | 52 | Controls cantbefrozen | Vinegar2 |
| `FishingLure` | 43 | Controls fishinglure | Baguette |
| `CannedFood` | 41 | Controls cannedfood | WaterRationCan |
| `DisappearOnUse` | 36 | Controls disappearonuse | GunLight |
| `RemoveUnhappinessWhenCooked` | 36 | Controls removeunhappinesswhencooked | Potato |
| `UseSelf` | 33 | Controls useself | Aerosolbomb |
| `RemoveOnBroken` | 33 | Controls removeonbroken | Shoes_ArmyBoots |
| `Medical` | 31 | Controls medical | Pills |
| `AlwaysWelcomeGift` | 29 | Controls alwayswelcomegift | Nails |
| `CanBePlaced` | 27 | Controls canbeplaced | AerosolbombRemote |
| `AlwaysKnockdown` | 25 | Controls alwaysknockdown | StoneMaul |
| `KeepOnDeplete` | 24 | Item remains after use | SheepElectricShears |
| `CantAttackWithLowestEndurance` | 22 | Controls cantattackwithlowestendurance | StoneMaul |
| `ConditionAffectsCapacity` | 22 | Controls conditionaffectscapacity | SmallGasTank1 |
| `ActivatedItem` | 20 | Controls activateditem | GunLight |
| `CanBeWrite` | 19 | Controls canbewrite | Journal |
| `TorchCone` | 18 | Controls torchcone | GunLight |
| `IsHighTier` | 17 | Controls ishightier | WalkieTalkie1 |
| `IsPortable` | 17 | Controls isportable | WalkieTalkie1 |
| `IsTelevision` | 17 | Controls istelevision | WalkieTalkie1 |
| `TwoWay` | 17 | Controls twoway | WalkieTalkie1 |
| `UsesBattery` | 17 | Controls usesbattery | WalkieTalkie1 |
| `IsAimedFirearm` | 16 | Controls isaimedfirearm | AssaultRifle |
| `MultipleHitConditionAffected` | 16 | Controls multiplehitconditionaffected | AssaultRifle |
| `Ranged` | 16 | Controls ranged | AssaultRifle |
| `UseEndurance` | 16 | Controls useendurance | AssaultRifle |
| `VisualAid` | 15 | Controls visualaid | Glasses_Prescription |
| `CanBarricade` | 12 | Controls canbarricade | BallPeenHammer |
| `CanBandage` | 11 | Can be used to bandage wounds | AlcoholBandage |
| `IsDung` | 10 | Controls isdung | Dung_Turkey |
| `PiercingBullets` | 9 | Controls piercingbullets | AssaultRifle |
| `PickRandomFluid` | 9 | Controls pickrandomfluid | HairDyeCommon |
| `CanStoreWater` | 7 | Controls canstorewater | Saucepan |
| `HaveChamber` | 7 | Controls havechamber | DoubleBarrelShotgun |
| `RackAfterShoot` | 7 | Controls rackaftershoot | DoubleBarrelShotgun |
| `CanBeReused` | 6 | Controls canbereused | NoiseTrap |
| `Trap` | 6 | Controls trap | TrapBox |
| `CanBeRemote` | 5 | Can be triggered remotely | AerosolbombRemote |
| `RemoveNegativeEffectOnCooked` | 5 | Controls removenegativeeffectoncooked | BreadDough |
| `Opened` | 5 | Controls opened | BeerBottle |
| `EquippedNoSprint` | 5 | Controls equippednosprint | UmbrellaBlack |
| `ProtectFromRainWhenEquipped` | 5 | Controls protectfromrainwhenequipped | UmbrellaBlack |
| `CanStack` | 5 | Controls canstack | 44Clip |
| `AngleFalloff` | 4 | Controls anglefalloff | DoubleBarrelShotgun |
| `RangeFalloff` | 4 | Controls rangefalloff | DoubleBarrelShotgun |
| `ManuallyRemoveSpentRounds` | 4 | Controls manuallyremovespentrounds | Revolver |
| `OtherHandUse` | 3 | Controls otherhanduse | Firecracker |
| `RemoteController` | 3 | Controls remotecontroller | RemoteCraftedV1 |
| `needtobeclosedoncereload` | 2 | Controls needtobeclosedoncereload | DoubleBarrelShotgun |
| `InsertAllBulletsReload` | 2 | Controls insertallbulletsreload | DoubleBarrelShotgun |
| `Alcoholic` | 2 | Contains alcohol | AlcoholBandage |
| `Wet` | 2 | Controls wet | BathTowelWet |
| `NoTransmit` | 1 | Controls notransmit | CDplayer |
| `DigitalPadlock` | 1 | Controls digitalpadlock | CombinationPadlock |
| `Padlock` | 1 | Controls padlock | Padlock |
| `IsWaterSource` | 1 | Can be used as water source | TestWaterMug |
| `UseWorldItem` | 1 | Controls useworlditem | PropaneTank |
| `UseWhileUnequipped` | 1 | Controls usewhileunequipped | CandleLit |


## Numeric Properties

### Damage & Combat

| Property | Type | Usage Count | Description | Example Values |
|----------|------|------------|-------------|----------------|
| `MaxDamage` | Float | 403 | Controls maxdamage | 0.8, 0.8 |
| `MaxHitcount` | Integer | 403 | Controls maxhitcount | 2, 2 |
| `MaxRange` | Float | 403 | Controls maxrange | 1.1, 1.1 |
| `MinDamage` | Float | 403 | Controls mindamage | 0.4, 0.4 |
| `Swingtime` | Float | 403 | Controls swingtime | 4.0, 4.0 |
| `MinimumSwingtime` | Float | 400 | Controls minimumswingtime | 4.0, 4.0 |
| `SwingAmountBeforeImpact` | Float | 395 | Controls swingamountbeforeimpact | 0.02, 0.02 |
| `KnockdownMod` | Float | 375 | Controls knockdownmod | 2.0, 2.0 |
| `DoorDamage` | Integer | 370 | Controls doordamage | 5, 1 |
| `PushBackMod` | Float | 370 | Controls pushbackmod | 0.3, 0.3 |
| `MinRange` | Float | 369 | Controls minrange | 0.61, 0.61 |
| `CriticalChance` | Float | 361 | Controls criticalchance | 15.0, 15.0 |
| `TreeDamage` | Integer | 354 | Controls treedamage | 5, 0 |
| `CritDmgMultiplier` | Float | 346 | Controls critdmgmultiplier | 2.0, 2.0 |
| `SplatNumber` | Integer | 333 | Controls splatnumber | 3, 3 |
| `ChanceToSpawnDamaged` | Integer | 79 | Controls chancetospawndamaged | 30, 30, 70 |
| `HitAngleMod` | Float | 62 | Controls hitanglemod | -30.0, -30.0 |
| `SplatSize` | Integer | 37 | Controls splatsize | 5, 5 |
| `MaxSightRange` | Float | 21 | Controls maxsightrange | 12.0, 16.0, 10.0 |
| `MinSightRange` | Integer | 21 | Controls minsightrange | 4, 8, 2 |
| `BaseVolumeRange` | Integer | 17 | Controls basevolumerange | 8, 10 |
| `MicRange` | Integer | 17 | Controls micrange | 5, 5 |
| `TransmitRange` | Integer | 17 | Controls transmitrange | 750, 2000 |
| `AimingPerkCritModifier` | Integer | 16 | Controls aimingperkcritmodifier | 6, 6 |
| `AimingPerkHitChanceModifier` | Integer | 16 | Controls aimingperkhitchancemodifier | 4, 4 |
| `HitChance` | Integer | 16 | Controls hitchance | 50, 50 |
| `SensorRange` | Integer | 15 | Controls sensorrange | 3, 4 |
| `NoiseRange` | Integer | 14 | Controls noiserange | 17, 17 |
| `ToHitModifier` | Float | 13 | Controls tohitmodifier | 1.5, 1.5 |
| `ExplosionRange` | Integer | 12 | Controls explosionrange | 6, 6 |
| `AimingPerkRangeModifier` | Integer | 12 | Controls aimingperkrangemodifier | 0, 0 |
| `FireRange` | Integer | 9 | Controls firerange | 6, 6 |
| `SmokeRange` | Integer | 6 | Controls smokerange | 5, 5 |
| `RemoteRange` | Integer | 3 | Controls remoterange | 7, 11 |
| `MaxRangeModifier` | Integer | 2 | Controls maxrangemodifier | 2, 1 |
| `HitChanceModifier` | Integer | 1 | Controls hitchancemodifier | 5 |

### Durability & Condition

| Property | Type | Usage Count | Description | Example Values |
|----------|------|------------|-------------|----------------|
| `ConditionMax` | Integer | 809 | Controls conditionmax | 10, 10, 100 |
| `ConditionLowerChanceOneIn` | Integer | 602 | Controls conditionlowerchanceonein | 15, 15, 2 |
| `HeadCondition` | Integer | 57 | Controls headcondition | 10, 10, 10 |
| `HeadConditionLowerChanceMultiplier` | Float | 54 | Controls headconditionlowerchancemultiplier | 2.0, 2.0, 1.0 |
| `ConditionLowerStandard` | Float | 27 | Controls conditionlowerstandard | 40.0, 25.0, 20.0 |
| `ConditionLowerOffroad` | Float | 24 | Controls conditionloweroffroad | 0.5, 0.4 |
| `HeadConditionMax` | Integer | 13 | Controls headconditionmax | 8, 6 |

### Item Stats & Effects

| Property | Type | Usage Count | Description | Example Values |
|----------|------|------------|-------------|----------------|
| `Weight` | Float | 4518 | Controls weight | 0.1, 0.3, 0.4 |
| `Insulation` | Float | 860 | Controls insulation | 0.15, 0.15, 0.8 |
| `WindResistance` | Float | 762 | Controls windresistance | 0.1, 0.1, 0.25 |
| `Capacity` | Float/Integer | 441 | Controls capacity | 0.6, 0.6, 1.0 |
| `WeightReduction` | Integer | 280 | Controls weightreduction | 65, 65 |
| `NeckProtectionModifier` | Float | 62 | Controls neckprotectionmodifier | 0.5, 0.5 |
| `MaxCapacity` | Integer | 46 | Controls maxcapacity | 30, 35 |
| `WeightEmpty` | Float | 17 | Controls weightempty | 0.1, 0.1, 0.1 |
| `WeightModifier` | Float | 11 | Controls weightmodifier | 0.3, 0.4 |
| `BandagePower` | Float | 11 | Controls bandagepower | 4.0, 2.0 |
| `ProjectileWeightCenter` | Float | 4 | Controls projectileweightcenter | 1.0, 1.0 |
| `WeaponWeight` | Integer | 3 | Controls weaponweight | 3, 3 |
| `ReduceInfectionPower` | Float | 3 | Controls reduceinfectionpower | 1.0, 1.0 |

### Other Numeric Properties

| Property | Type | Usage Count | Example Values |
|----------|------|------------|----------------|
| `HungerChange` | Float | 608 | -10.0, -100.0, -10.0 |
| `ScratchDefense` | Integer | 607 | 10, 5 |
| `Calories` | Float | 600 | 0.0, 0.0, 516.0 |
| `Carbohydrates` | Float | 600 | 0.0, 0.0, 36.0 |
| `Lipids` | Float | 600 | 0.0, 0.0, 41.5 |
| `Proteins` | Float | 600 | 0.0, 0.0, 4.8 |
| `DaysFresh` | Integer | 497 | 3, 3 |
| `DaysTotallyRotten` | Integer | 497 | 5, 7 |
| `RunSpeedModifier` | Float | 434 | 0.97, 0.9, 0.9 |
| `BiteDefense` | Integer | 421 | 15, 15 |
| `UnhappyChange` | Integer | 412 | 50, 500, -10 |
| `MetalValue` | Float | 385 | 22.0, 22.0, 1.0 |
| `MinAngle` | Float | 370 | 0.65, 0.65 |
| `DiscomfortModifier` | Float | 344 | 0.12, 0.1, 0.05 |
| `StressChange` | Integer | 273 | 1, -5, -1 |
| `BoredomChange` | Integer | 273 | 10, 10, -20 |
| `BaseSpeed` | Float | 264 | 1.2, 1.2 |
| `WeaponLength` | Float | 262 | 0.2, 0.2 |
| `ChanceToFall` | Integer | 257 | 10, 10, 80 |
| `MinutesToCook` | Integer | 249 | 10, 10 |
| `MinutesToBurn` | Integer | 246 | 50, 30 |
| `WaterResistance` | Float | 186 | 1.0, 1.0 |
| `CombatSpeedModifier` | Float | 172 | 0.99, 0.98, 0.98 |
| `UseDelta` | Float | 165 | 0.001, 0.007, 0.008 |
| `ColorBlue` | Integer | 131 | 210, 10, 28 |
| `ColorGreen` | Integer | 131 | 50, 220, 133 |
| `ColorRed` | Integer | 131 | 50, 10, 230 |
| `LvlSkillTrained` | Integer | 120 | 1, 3 |
| `NumLevelsTrained` | Integer | 120 | 2, 2 |
| `NumberOfPages` | Integer | 120 | 220, 260 |
| `Sharpness` | Float | 112 | 1.0, 1.0, 1.0 |
| `ThirstChange` | Float | 112 | -20.0, -1.0 |
| `BulletDefense` | Integer | 101 | 100, 100 |
| `FireFuelRatio` | Float | 96 | 0.75, 0.75, 0.25 |
| `VehicleType` | Integer | 91 | 1, 2, 1 |
| `VisionModifier` | Float | 83 | 0.75, 0.75 |
| `AimingMod` | Float | 67 | 2.0, 2.0 |
| `RainFactor` | Float | 52 | 0.8, 0.5, 0.2 |
| `MaxItemSize` | Float | 49 | 2.0, 2.0 |
| `SoundRadius` | Integer | 38 | 7, 15, 150 |
| `EnduranceMod` | Float | 38 | 2.0, 1.3 |
| `HearingModifier` | Float | 36 | 0.75, 0.5 |
| `StompPower` | Float | 28 | 2.5, 2.5 |
| `FireStartingEnergy` | Integer | 25 | 20, 20 |
| `FireStartingChance` | Integer | 25 | 10, 10 |
| `Eattime` | Integer | 25 | 160, 460, 160 |
| `MaxAmmo` | Integer | 21 | 30, 20, 8 |
| `ExplosionTimer` | Integer | 20 | 5, 5 |
| `SoundVolume` | Integer | 20 | 35, 30, 1 |
| `PageToWrite` | Integer | 19 | 20, 10 |
| `LightDistance` | Integer | 18 | 15, 5, 5 |
| `LightStrength` | Float | 18 | 1.3, 0.8, 0.6 |
| `MaxChannel` | Integer | 17 | 150000, 200000 |
| `MinChannel` | Integer | 17 | 75000, 50000 |
| `CorpseSicknessDefense` | Float | 17 | 25.0, 25.0 |
| `Aimingtime` | Integer | 16 | 40, 50 |
| `JamGunChance` | Integer | 16 | 1, 1 |
| `Projectilecount` | Integer | 16 | 1, 1 |
| `RecoilDelay` | Integer | 16 | 15, 20 |
| `Reloadtime` | Integer | 16 | 25, 25 |
| `SoundGain` | Float | 16 | 2.0, 2.0 |
| `StopPower` | Float | 16 | 2.0, 2.0 |
| `count` | Integer | 15 | 5, 5 |
| `InitialPercentMin` | Float | 14 | 0.0, 0.0, 0.1 |
| `InitialPercentMax` | Float | 14 | 1.0, 1.0, 1.0 |
| `NPCSoundBoost` | Float | 13 | 1.5, 1.5 |
| `ExplosionPower` | Integer | 12 | 70, 70 |
| `NoiseDuration` | Integer | 12 | 30, 30 |
| `AimingPerkMinAngleModifier` | Float | 12 | 0.01, 0.01 |
| `FoodSicknessChange` | Integer | 12 | 100, 10, -12 |
| `wheelFriction` | Float | 9 | 1.2, 1.4 |
| `brakeForce` | Integer | 9 | 17, 20 |
| `engineLoudness` | Float | 9 | 80.0, 100.0 |
| `AimingTimeModifier` | Integer | 7 | 5, 10 |
| `TorchDot` | Float | 7 | 0.66, 0.5, 0.5 |
| `ClipSize` | Integer | 7 | 20, 15 |
| `InverseCoughProbability` | Integer | 7 | 10, 4, 10 |
| `InverseCoughProbabilitySmoker` | Integer | 7 | 2, 2, 2 |
| `ExplosionDuration` | Integer | 6 | 10, 10 |
| `suspensionDamping` | Float | 6 | 2.88, 2.88 |
| `suspensionCompression` | Float | 6 | 3.83, 3.83 |
| `ProjectileSpread` | Float | 4 | 0.6, 2.0 |
| `AcceptMediaType` | Integer | 4 | 0, 0 |
| `fatigueChange` | Float | 4 | -4.0, -50.0, -15.0 |
| `PoisonPower` | Integer | 4 | 1, 1 |
| `ShoutMultiplier` | Float | 4 | 2.0, 1.5, 2.0 |
| `triggerExplosionTimer` | Integer | 3 | 50, 50 |
| `ticksPerEquipUse` | Integer | 3 | 130, 110 |
| `ProjectileSpreadModifier` | Float | 2 | -0.4, -0.2 |
| `OriginX` | Integer | 2 | 0, 0 |
| `OriginY` | Integer | 2 | 0, 0 |
| `originZ` | Integer | 2 | 0, 0 |
| `AlcoholPower` | Float | 2 | 4.0, 4.0 |
| `painReduction` | Integer | 2 | 7, 7 |
| `fluReduction` | Integer | 2 | 5, 5 |
| `WetCooldown` | Float | 2 | 10000.0, 8000.0 |
| `ReloadTimeModifier` | Integer | 1 | -5 |
| `LowLightBonus` | Float | 1 | 5.0 |
| `RecoilDelayModifier` | Float | 1 | -2.0 |
| `CyclicRateMultiplier` | Float | 1 | 1.0 |
| `ScaleWorldIcon` | Float | 1 | 2.0 |
| `enduranceChange` | Float | 1 | 2.0 |


## String Properties

### Visual & Audio

| Property | Usage Count | Description | Example Values |
|----------|------------|-------------|----------------|
| `Icon` | 4676 | Controls icon | `WoolRaw`, `Scope2x` |
| `WorldStaticModel` | 3845 | Controls worldstaticmodel | `Rifle_2XScope_Ground`, `Rifle_4XScope_Ground` |
| `StaticModel` | 1558 | Controls staticmodel | `RedDot`, `GunLight` |
| `BreakSound` | 592 | Controls breaksound | `MeatCleaverBreak`, `MeatCleaverBreak` |
| `WorldObjectSprite` | 406 | Controls worldobjectsprite | `appliances_com_01_16`, `appliances_com_01_24` |
| `SwingSound` | 402 | Controls swingsound | `MeatCleaverSwing`, `MeatCleaverSwing` |
| `SwingAnim` | 400 | Controls swinganim | `Bat`, `Bat` |
| `WeaponSprite` | 378 | Controls weaponsprite | `GardenFork_Head`, `GardenFork_Head` |
| `HitSound` | 369 | Controls hitsound | `MeatCleaverHit`, `MeatCleaverHit` |
| `DoorHitSound` | 354 | Controls doorhitsound | `MeatCleaverHit`, `MeatCleaverHit` |
| `HitFloorSound` | 354 | Controls hitfloorsound | `MeatCleaverHit`, `MeatCleaverHit` |
| `DropSound` | 326 | Controls dropsound | `MeatCleaverDrop`, `MeatCleaverDrop` |
| `CloseSound` | 306 | Controls closesound | `CloseBag`, `CloseBag` |
| `OpenSound` | 306 | Controls opensound | `OpenBag`, `OpenBag` |
| `PutInSound` | 306 | Controls putinsound | `PutItemInBag`, `PutItemInBag` |
| `RunAnim` | 288 | Controls runanim | `Run_Weapon2`, `Run_Weapon2` |
| `IdleAnim` | 262 | Controls idleanim | `Idle_Weapon2`, `Idle_Weapon2` |
| `IconsForTexture` | 222 | Controls iconsfortexture | `BallPeenHammer;BallPeenHammer_`, `ClubHammer_Forged;ClubHammer` |
| `BulletHitArmourSound` | 213 | Controls bullethitarmoursound | `ArmourFirearmHitChainmail`, `ArmourFirearmHitChainmail` |
| `WeaponHitArmourSound` | 213 | Controls weaponhitarmoursound | `ArmourMeleeHitChainmail`, `ArmourMeleeHitChainmail` |
| `CookingSound` | 203 | Controls cookingsound | `BoilingFood`, `FryingFood` |
| `CustomEatSound` | 127 | Controls customeatsound | ``, `DrinkingFromCan` |
| `ImpactSound` | 123 | Controls impactsound | `HandShovelHit`, `HandShovelHit` |
| `CustomDrinkSound` | 102 | Controls customdrinksound | `DrinkingFromBottlePlastic`, `DrinkingFromMug` |
| `SoundMap` | 97 | Controls soundmap | `Activate FlashlightOn`, `Deactivate FlashlightOff` |
| `EquipSound` | 91 | Controls equipsound | `EntrenchingToolEquip`, `M16Equip` |
| `IconColorMask` | 86 | Controls iconcolormask | `Umbrella_Mask`, `Lipstick_Mask` |
| `FillFromDispenserSound` | 84 | Controls fillfromdispensersound | `GetWaterFromDispenserCeramic`, `GetWaterFromDispenserMetalMedi` |
| `FillFromTapSound` | 84 | Controls fillfromtapsound | `GetWaterFromTapCeramic`, `GetWaterFromTapMetalMedium` |
| `FillFromLakeSound` | 83 | Controls fillfromlakesound | `GetWaterFromLakeSmall`, `GetWaterFromLakeBottle` |
| `IconFluidMask` | 73 | Controls iconfluidmask | `Saucepan_Mask`, `Saucepan_Mask` |
| `FillFromToiletSound` | 71 | Controls fillfromtoiletsound | `GetWaterFromToilet`, `GetWaterFromToilet` |
| `ModelWeaponPart` | 35 | Controls modelweaponpart | `TritiumSights IronSight scope2`, `Laser Laser laser laser` |
| `WorldStaticModelsByIndex` | 34 | Controls worldstaticmodelsbyindex | `KnifeButterflyClosed;KnifeButt`, `KnifePocketClosed;KnifePocketC` |
| `SoundParameter` | 34 | Controls soundparameter | `EquippedBaggageContainer Schoo`, `EquippedBaggageContainer Schoo` |
| `ExplosionSound` | 33 | Controls explosionsound | `AerosolBombExplode`, `AerosolBombExplode` |
| `primaryAnimMask` | 27 | Controls primaryanimmask | `HoldingTorchRight`, `HoldingTorchRight` |
| `secondaryAnimMask` | 27 | Controls secondaryanimmask | `HoldingTorchLeft`, `HoldingTorchLeft` |
| `WeaponSpritesByIndex` | 25 | Controls weaponspritesbyindex | `SpadeHead2`, `BallPeenHammer;BallPeenHammerF` |
| `UnequipSound` | 25 | Controls unequipsound | `EntrenchingToolUnequip`, `M16UnEquip` |
| `AnimalFeedType` | 24 | Controls animalfeedtype | `AnimalFeed`, `Grass` |
| `PlacedSprite` | 23 | Controls placedsprite | `constructedobjects_01_32`, `constructedobjects_01_32` |
| `PlaceOneSound` | 20 | Controls placeonesound | `CorpseDrop`, `CorpseDrop` |
| `AlarmSound` | 18 | Controls alarmsound | `PocketWatchRinging`, `AlarmClockRingingLoop` |
| `PlaceMultipleSound` | 18 | Controls placemultiplesound | `BoxOfRoundsPlaceAll`, `BoxOfRoundsPlaceAll` |
| `AimReleaseSound` | 16 | Controls aimreleasesound | `M16AimRelease`, `M14AimRelease` |
| `BringToBearSound` | 16 | Controls bringtobearsound | `M16BringToBear`, `M14BringToBear` |
| `ClickSound` | 16 | Controls clicksound | `M16Jam`, `M14Jam` |
| `InsertAmmoSound` | 16 | Controls insertammosound | `M16InsertAmmo`, `M14InsertAmmo` |
| `MuzzleFlashModelKey` | 16 | Controls muzzleflashmodelkey | `muzzle_flash_assault_rifle`, `muzzle_flash_assault_rifle02` |
| `EjectAmmoSound` | 15 | Controls ejectammosound | `M16EjectAmmo`, `M14EjectAmmo` |
| `EjectAmmoStartSound` | 15 | Controls ejectammostartsound | `M16EjectAmmoStart`, `M14EjectAmmoStart` |
| `EjectAmmoStopSound` | 15 | Controls ejectammostopsound | `M16EjectAmmoStop`, `M14EjectAmmoStop` |
| `InsertAmmoStartSound` | 15 | Controls insertammostartsound | `M16InsertAmmoStart`, `M14InsertAmmoStart` |
| `InsertAmmoStopSound` | 15 | Controls insertammostopsound | `M16InsertAmmoStop`, `M14InsertAmmoStop` |
| `ShellFallSound` | 14 | Controls shellfallsound | `M16CartridgeFall`, `M14CartridgeFall` |
| `StaticModelsByIndex` | 14 | Controls staticmodelsbyindex | `Cereal;Cereal2;Cereal3;Cereal4`, `Mug;MugRed;MugWhite;MugBlue;Mu` |
| `RackSound` | 10 | Controls racksound | `M16Rack`, `M14Rack` |
| `VehiclePartModel` | 3 | Controls vehiclepartmodel | `HoodOrnament Default HoodOrnam`, `HoodOrnament Default HoodOrnam` |

### Categories & Classification

| Property | Usage Count | Description | Example Values |
|----------|------------|-------------|----------------|
| `ItemType` | 5098 | Controls itemtype | `base:animal`, `base:weaponpart` |
| `DisplayCategory` | 5098 | Controls displaycategory | `Generic`, `WeaponPart` |
| `Tags` | 3492 | Controls tags | `base:optics`, `base:optics` |
| `FabricType` | 417 | Controls fabrictype | `Cotton`, `Cotton` |
| `SubCategory` | 369 | Controls subcategory | `Swinging`, `Swinging` |
| `FoodType` | 364 | Controls foodtype | `Dressing`, `Dressing` |
| `AttachmentType` | 347 | Controls attachmenttype | `NotKnife`, `Shovel` |
| `EatType` | 327 | Controls eattype | `Saucepan`, `Saucepan` |
| `DamageCategory` | 163 | Controls damagecategory | `Slash`, `Slash` |
| `ReadType` | 152 | Controls readtype | `photo`, `photo` |
| `PourType` | 97 | Controls pourtype | `Mug`, `Bucket` |
| `AnimalFeedType` | 24 | Controls animalfeedtype | `AnimalFeed`, `Grass` |
| `AmmoType` | 21 | Controls ammotype | `base:bullets_556`, `base:bullets_308` |
| `HerbalistType` | 18 | Controls herbalisttype | `Berry`, `Berry` |
| `WeaponReloadType` | 16 | Controls weaponreloadtype | `boltaction`, `boltaction` |
| `DigType` | 15 | Controls digtype | `Trowel`, `Trowel` |
| `PartType` | 11 | Controls parttype | `Scope`, `Scope` |
| `MagazineType` | 5 | Controls magazinetype | `Base.556Clip`, `Base.M14Clip` |
| `GunType` | 5 | Controls guntype | `Base.Pistol3`, `Base.Pistol2` |
| `ShoutType` | 4 | Controls shouttype | `BlowWhistle`, `BlowHarmonica` |
| `MakeUpType` | 3 | Controls makeuptype | `Lips`, `Eyes` |
| `MediaCategory` | 3 | Controls mediacategory | `CDs`, `Retail-VHS` |

### Other String Properties

| Property | Usage Count | Example Values |
|----------|------------|----------------|
| `ClothingItem` | 1580 | `Bag_ManPackRadio`, `WristWatch_Right_ClassicBlack` |
| `BodyLocation` | 1432 | `base:rightwrist`, `base:leftwrist` |
| `Researchablerecipes` | 955 | `MakeSpadeHeadCudgel;Forge_Spad`, `MakeGardenForkHeadWeapon` |
| `BloodLocation` | 908 | `Bag`, `ShortsShort;Shirt` |
| `Tooltip` | 413 | `Tooltip_Scope`, `Tooltip_Scope` |
| `EvolvedRecipe` | 374 | `Sandwich:1;Burger:1;Rice:1;Pas`, `Sandwich:1;Burger:1;Rice:1;Pas` |
| `OnCreate` | 367 | `ItemCodeOnCreate.onCreateIDCar`, `Fishing.onCreateFishingRod` |
| `ClothingExtraSubmenu` | 360 | `RightWrist`, `LeftWrist` |
| `ClothingItemExtra` | 360 | `Base.WristWatch_Left_ClassicBl`, `Base.WristWatch_Right_ClassicB` |
| `ClothingItemExtraOption` | 360 | `LeftWrist`, `RightWrist` |
| `Categories` | 354 | `base:blunt`, `base:blunt` |
| `ReplaceInSecondHand` | 219 | `Bag_ManPackRadio_LHand holding`, `Bag_Sandbag_LHand holdingbagle` |
| `ReplaceInPrimaryHand` | 218 | `Bag_ManPackRadio_RHand holding`, `Bag_Sandbag_RHand holdingbagri` |
| `LearnedRecipes` | 199 | `Forge_Tongs;Forge_Heading_Tool`, `base:kitchentools;Forge_Cookin` |
| `OnBreak` | 193 | `OnBreak.BallPeenHammer`, `OnBreak.BallPeenHammer` |
| `DoubleClickRecipe` | 179 | `ExtinguishHurricaneLantern`, `LightHurricaneLantern` |
| `EvolvedRecipeName` | 173 | `Vinegar`, `Strawberry` |
| `fluid` | 149 | `Water:1.0`, `Water:1.0` |
| `ContainerName` | 133 | `Saucepan`, `Saucepan` |
| `book_subject` | 122 | `base:classic`, `base:classic` |
| `SkillTrained` | 120 | `Carpentry`, `Carpentry` |
| `ReplaceOnUse` | 116 | `Base.PanForged`, `Base.TestMug` |
| `CanBeEquipped` | 87 | `base:back`, `base:back` |
| `CloseKillMove` | 59 | `Jaw_Stab`, `Jaw_Stab` |
| `CustomContextMenu` | 57 | `Eat`, `Sniff` |
| `SpawnWith` | 48 | `Base.ElbowPad_Left_Leather`, `Base.ElbowPad_Right_Leather` |
| `magazine_subject` | 48 | `base:art`, `base:business` |
| `ReplaceOnDeplete` | 41 | `Base.CeramicCrucible`, `Base.CeramicCrucible` |
| `AcceptItemFunction` | 41 | `AcceptItemFunction.Wallet`, `AcceptItemFunction.Wallet` |
| `PhysicsObject` | 33 | `Base.Aerosolbomb`, `Base.Aerosolbomb` |
| `AttachmentsProvided` | 28 | `HolsterAnkle`, `HolsterLeft;HolsterRight` |
| `AttachmentReplacement` | 26 | `Bag`, `Bag` |
| `OnEat` | 23 | `RecipeCodeOnEat.consumeRatPois`, `RecipeCodeOnEat.consumeCorrect` |
| `OpeningRecipe` | 22 | `OpenCannedFood`, `OpenCannedFood` |
| `AmmoBox` | 16 | `Base.556Box`, `Base.308Box` |
| `ConsolidateOption` | 16 | `ContextMenu_Merge`, `ContextMenu_Merge` |
| `Map` | 14 | `LouisvilleMap1`, `LouisvilleMap2` |
| `MountOn` | 11 | `Base.HuntingRifle;Base.Varmint`, `Base.HuntingRifle;Base.Varmint` |
| `OnCooked` | 11 | `RecipeCodeOnCooked.cannedFood`, `RecipeCodeOnCooked.cannedFood` |
| `CanAttach` | 9 | `ItemCodeOnTest.hasScrewdriver`, `ItemCodeOnTest.hasScrewdriver` |
| `CanDetach` | 9 | `ItemCodeOnTest.hasScrewdriver`, `ItemCodeOnTest.hasScrewdriver` |
| `FireMode` | 8 | `Auto`, `Single` |
| `ReplaceOnRotten` | 8 | `Base.SugarBeetSugarPot`, `Base.ConeIcecreamMelted` |
| `RequireInHandOrInventory` | 7 | `Base.CandleLit/Base.Matches/Ba`, `Base.CandleLit/Base.Matches/Ba` |
| `ReplaceOnExtinguish` | 6 | `Base.Lantern_Hurricane`, `Base.Lantern_Hurricane_Copper` |
| `WithoutDrainable` | 5 | `Base.Hat_BuildersRespirator_no`, `Base.Hat_GasMask_nofilter` |
| `WithDrainable` | 5 | `Base.Hat_BuildersRespirator`, `Base.Hat_GasMask` |
| `ItemAfterCleaning` | 4 | `Base.Bandage`, `Base.DenimStrips` |
| `OtherHandRequire` | 3 | `base:lighter`, `base:lighter` |
| `ReplaceOnCooked` | 3 | `Base.Toast`, `Base.Baguette` |
| `ItemWhenDry` | 2 | `Base.BathTowel`, `Base.DishCloth` |
| `FireModePossibilities` | 1 | `Auto/Single` |
| `menu` | 1 | `CarBatteryCharger_Place` |
| `customFunction` | 1 | `ContextMenuCode.Items.PlaceCar` |

---

## Determining Item Rarity

### Recommended Approach

Item rarity can be determined using a multi-factor analysis:

1. **Spawn Frequency** (Primary Factor)
   - Parse `ProceduralDistributions.lua` to get spawn weights
   - Lower spawn weight = Higher rarity

2. **Static Properties** (Secondary Factors)
   - `Weight`: Extremely light or heavy items often rare
   - `ConditionMax`: Higher durability may indicate rarity
   - `MaxDamage`: Higher damage output for weapons
   - `DisplayCategory`: Certain categories like SurvivalGear are rarer

3. **Tags Analysis**
   - Items with `base:military`, `base:police` tags tend to be rare
   - `base:tactical`, `base:survivalgear` indicate higher tier

4. **Boolean Indicators**
   - `MultiStage`: Complex craftable items
   - `TwoHandWeapon`: Often indicates powerful weapons
   - `RequiresEquippedBothHands`: Heavy/powerful items

### Suggested Rarity Tiers

- **Common**: High spawn weight (>5), basic functionality, low stats
- **Uncommon**: Medium spawn weight (2-5), moderate stats, specialized categories
- **Rare**: Low spawn weight (0.5-2), high stats, military/police tags
- **Legendary**: Very low spawn weight (<0.5), exceptional stats, unique properties

