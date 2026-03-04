require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
-- =============================================================================
-- 1. RAW MEAT (Butchery Results)
-- =============================================================================
-- Note: Prime/Average/Poor cuts share IDs. Price is averaged.
{ item="Base.Beef", basePrice=75, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Steak", basePrice=85, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=4} },
{ item="Base.Pork", basePrice=65, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.PorkChop", basePrice=55, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.MuttonChop", basePrice=55, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Venison", basePrice=90, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=1, max=3} },
{ item="Base.ChickenWhole", basePrice=100, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=3} },
{ item="Base.TurkeyWhole", basePrice=150, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.Rabbitmeat", basePrice=45, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Common"}, stockRange={min=1, max=5} },
{ item="Base.Smallanimalmeat", basePrice=25, tags={"Food.Meat.Perishable", "Theme.Survival", "Rarity.Common"}, stockRange={min=2, max=10} },

-- Skinned Carcasses (Gross but edible)
-- Skinned Carcasses (Gross but edible)
{ item="Base.DeadMouseSkinned",     basePrice=2, tags={"Food.Meat.Perishable", "Theme.Survival", "Quality.Junk"}, stockRange={min=1, max=5} },
{ item="Base.DeadMousePupsSkinned", basePrice=1, tags={"Food.Meat.Perishable", "Theme.Survival", "Quality.Junk"}, stockRange={min=1, max=5} },
{ item="Base.DeadRatSkinned",       basePrice=3, tags={"Food.Meat.Perishable", "Theme.Survival", "Quality.Junk"}, stockRange={min=1, max=5} },
{ item="Base.DeadRatBabySkinned",   basePrice=1, tags={"Food.Meat.Perishable", "Theme.Survival", "Quality.Junk"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 2. HIDES & LEATHER (Crafting Materials)
-- =============================================================================

-- Large Hides (High Value)
-- Large Hides
{ item="Base.CowLeather_Angus_Full",      basePrice=180, tags={"Resource.Material.Leather", "Origin.Industrial", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.CowLeather_Holstein_Full",   basePrice=180, tags={"Resource.Material.Leather", "Origin.Industrial", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.CowLeather_Simmental_Full",  basePrice=180, tags={"Resource.Material.Leather", "Origin.Industrial", "Rarity.Uncommon"}, stockRange={min=0, max=1} },
{ item="Base.DeerLeather_Full",           basePrice=150, tags={"Resource.Material.Leather", "Theme.Survival", "Rarity.Uncommon"}, stockRange={min=1, max=2} },

-- Medium Hides
{ item="Base.PigLeather_Black_Full",      basePrice=100, tags={"Resource.Material.Leather", "Origin.Industrial", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.PigLeather_Landrace_Full",   basePrice=100, tags={"Resource.Material.Leather", "Origin.Industrial", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.SheepLeather_Full",          basePrice=100, tags={"Resource.Material.Leather", "Origin.Industrial", "Rarity.Uncommon"}, stockRange={min=1, max=2} },

-- Small Hides
{ item="Base.RabbitLeather_Full",         basePrice=45,  tags={"Resource.Material.Leather", "Theme.Survival", "Rarity.Common"}, stockRange={min=2, max=5} },
{ item="Base.RaccoonLeather_Grey_Full",   basePrice=45,  tags={"Resource.Material.Leather", "Theme.Survival", "Rarity.Common"}, stockRange={min=2, max=5} },

-- =============================================================================
-- 3. TROPHIES: HEADS (Decor / Biology)
-- =============================================================================
-- Rotting heads are cheap unless taxidermy is involved (assumed fresh here)

-- Livestock
-- Livestock
{ item="Base.Bull_Head_Angus",          basePrice=10, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Bull_Head_Simmental",      basePrice=10, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Bull_Head_Holstein",       basePrice=10, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Cow_Head_Angus",           basePrice=8,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Cow_Head_Simmental",       basePrice=8,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Cow_Head_Holstein",        basePrice=8,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Boar_Head_Black",      basePrice=8,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Boar_Head_Pink",       basePrice=8,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Sow_Head_Black",       basePrice=6,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Sow_Head_Pink",        basePrice=6,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Ram_Head_White",     basePrice=8,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Ram_Head_Black",     basePrice=8,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },

-- Wild Game
-- Wild Game
{ item="Base.Deer_Buck_Head",           basePrice=20, tags={"Resource.Material.Trophy", "Rarity.Rare"}, stockRange={min=0, max=1} }, -- Impressive rack
{ item="Base.Deer_Doe_Head",            basePrice=8,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Raccoon_Boar_Head",        basePrice=5,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=2} },
{ item="Base.Raccoon_Sow_Head",         basePrice=5,  tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=2} },

-- Small/Juvenile Heads (Junk mostly)
-- Small/Juvenile Heads (Junk mostly)
{ item="Base.Calf_Head_Angus",          basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Calf_Head_Holstein",       basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Calf_Head_Simmental",      basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Deer_Fawn_Head",           basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Piglet_Head_Pink",     basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Piglet_Head_Black",    basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Lamb_Head_White",    basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Lamb_Head_Black",    basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },

-- Poultry Heads
-- Poultry Heads
{ item="Base.Chicken_Rooster_Head_White", basePrice=1, tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=5} },
{ item="Base.Chicken_Rooster_Head_Brown", basePrice=1, tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=5} },
{ item="Base.Chicken_Hen_Brown_Head",     basePrice=1, tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=5} },
{ item="Base.Chicken_Hen_White_Head",     basePrice=1, tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=5} },
{ item="Base.Turkey_Gobbler_Head",        basePrice=2, tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=3} },
{ item="Base.Turkey_Hen_Head",            basePrice=2, tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=3} },

-- =============================================================================
-- 4. TROPHIES: SKULLS (Permanent Decor)
-- =============================================================================
{ item="Base.Bull_Skull",               basePrice=15, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Cow_Skull",                basePrice=12, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.DeerStag_Skull",           basePrice=25, tags={"Resource.Material.Trophy", "Rarity.Rare"}, stockRange={min=0, max=1} },
{ item="Base.DeerDoe_Skull",            basePrice=10, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Ram_Skull",                basePrice=12, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Skull",              basePrice=10, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Skull",                basePrice=10, tags={"Resource.Material.Trophy", "Rarity.Common"}, stockRange={min=0, max=1} },

-- Small Skulls
{ item="Base.Calf_Skull",               basePrice=3,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Piglet_Skull",             basePrice=3,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Lamb_Skull",               basePrice=3,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.DeerFawn_Skull",           basePrice=3,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=1} },
{ item="Base.Raccoon_Skull",            basePrice=3,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=2} },
{ item="Base.Rabbit_Skull",             basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=3} },
{ item="Base.Chicken_Rooster_Skull",    basePrice=1,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=5} },
{ item="Base.Chicken_Hen_Skull",        basePrice=1,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=5} },
{ item="Base.Turkey_Skull",             basePrice=2,  tags={"Resource.Material.Trophy", "Quality.Junk"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 5. BONES & BYPRODUCTS
-- =============================================================================
{ item="Base.AnimalBone",           basePrice=5,   tags={"Resource.Material.Bone", "Rarity.Common"}, stockRange={min=5, max=20} },
{ item="Base.LargeAnimalBone",      basePrice=15,  tags={"Resource.Material.Bone", "Rarity.Common"}, stockRange={min=2, max=10} },
{ item="Base.SmallAnimalBone",      basePrice=2,   tags={"Resource.Material.Bone", "Quality.Junk"}, stockRange={min=5, max=30} },
{ item="Base.SharpBoneFragment",    basePrice=1,   tags={"Resource.Material.Bone", "Quality.Junk"}, stockRange={min=5, max=30} },
{ item="Base.AnimalSinew",          basePrice=25,  tags={"Resource.Material.Thread", "Origin.Animal", "Rarity.Uncommon"}, stockRange={min=2, max=10} }, -- Useful for stitching
{ item="Base.Animal_Brain",         basePrice=10,  tags={"Food.Meat.Perishable", "Theme.Survival"}, stockRange={min=1, max=5} }, -- Edible if desperate
{ item="Base.Animal_Brain_Small",   basePrice=5,   tags={"Food.Meat.Perishable", "Theme.Survival"}, stockRange={min=1, max=5} },
{ item="Base.ChickenFeather",       basePrice=1,   tags={"Resource.Material.Feather", "Quality.Junk"}, stockRange={min=10, max=50} },
{ item="Base.TurkeyFeather",        basePrice=1,   tags={"Resource.Material.Feather", "Quality.Junk"}, stockRange={min=10, max=50} },
{ item="Base.ChickenFoot",          basePrice=2,   tags={"Food.Meat.Perishable", "Quality.Junk"}, stockRange={min=2, max=10} },
{ item="Base.HerbivoreTeeth",       basePrice=1,   tags={"Resource.Material.Bone", "Quality.Junk"}, stockRange={min=1, max=10} },
{ item="Base.PigTusk",              basePrice=15,  tags={"Resource.Material.Trophy", "Rarity.Uncommon"}, stockRange={min=1, max=5} },
{ item="Base.JawboneBovide",        basePrice=10,  tags={"Resource.Material.Bone", "Rarity.Common"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 6. PRIMITIVE WEAPONS (Bone Crafted)
-- =============================================================================
{ item="Base.BoneClub",             basePrice=60,  tags={"Weapon.Melee.Primitive", "Quality.Primitive", "Rarity.Common"}, stockRange={min=1, max=2} },
{ item="Base.BoneClub_Spiked",      basePrice=85,  tags={"Weapon.Melee.Primitive", "Quality.Primitive", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.LargeBoneClub",        basePrice=85,  tags={"Weapon.Melee.Primitive", "Quality.Primitive", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
{ item="Base.LargeBoneClub_Spiked", basePrice=120, tags={"Weapon.Melee.Primitive", "Quality.Primitive", "Rarity.Uncommon"}, stockRange={min=1, max=2} },
})

print("[DynamicTrading] Animal Products Registry Complete \n.")
