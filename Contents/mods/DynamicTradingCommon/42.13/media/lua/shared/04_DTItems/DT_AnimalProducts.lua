require "01_DynamicTrading_Config"

if not DynamicTrading then return end

local function Register(list)
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
end

Register({
-- =============================================================================
-- 1. RAW MEAT (Butchery Results)
-- =============================================================================
-- Note: Prime/Average/Poor cuts share IDs. Price is averaged.
{ item="Base.Beef", basePrice=16, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Steak", basePrice=18, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=8} },
{ item="Base.Pork", basePrice=14, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.PorkChop", basePrice=12, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.MuttonChop", basePrice=12, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Venison", basePrice=18, tags={"Food", "Meat", "Fresh"}, stockRange={min=1, max=5} },
{ item="Base.ChickenWhole", basePrice=20, tags={"Food", "Meat", "Fresh"}, stockRange={min=1, max=4} },
{ item="Base.TurkeyWhole", basePrice=30, tags={"Food", "Meat", "Fresh"}, stockRange={min=0, max=2} }, -- High Calorie Bomb
{ item="Base.Rabbitmeat", basePrice=10, tags={"Food", "Meat", "Fresh"}, stockRange={min=2, max=10} },
{ item="Base.Smallanimalmeat", basePrice=4, tags={"Food", "Meat", "Fresh"}, stockRange={min=5, max=20} }, -- Raccoon/Rodent

-- Skinned Carcasses (Gross but edible)
{ item="Base.DeadMouseSkinned",     basePrice=2, tags={"Food", "Meat", "Fresh", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.DeadMousePupsSkinned", basePrice=1, tags={"Food", "Meat", "Fresh", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.DeadRatSkinned",       basePrice=3, tags={"Food", "Meat", "Fresh", "Junk"}, stockRange={min=1, max=5} },
{ item="Base.DeadRatBabySkinned",   basePrice=1, tags={"Food", "Meat", "Fresh", "Junk"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 2. HIDES & LEATHER (Crafting Materials)
-- =============================================================================

-- Large Hides (High Value)
{ item="Base.CowLeather_Angus_Full",      basePrice=45, tags={"Material", "Leather"}, stockRange={min=0, max=2} },
{ item="Base.CowLeather_Holstein_Full",   basePrice=45, tags={"Material", "Leather"}, stockRange={min=0, max=2} },
{ item="Base.CowLeather_Simmental_Full",  basePrice=45, tags={"Material", "Leather"}, stockRange={min=0, max=2} },
{ item="Base.DeerLeather_Full",           basePrice=35, tags={"Material", "Leather"}, stockRange={min=1, max=3} },

-- Medium Hides
{ item="Base.PigLeather_Black_Full",      basePrice=25, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.PigLeather_Landrace_Full",   basePrice=25, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.SheepLeather_Full",          basePrice=25, tags={"Material", "Leather"}, stockRange={min=1, max=3} },

-- Small/Juvenile Hides (Lower Value)
{ item="Base.CalfLeather_Angus_Full",     basePrice=15, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.CalfLeather_Holstein_Full",  basePrice=15, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.CalfLeather_Simmental_Full", basePrice=15, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.FawnLeather_Full",           basePrice=12, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.PigletLeather_Black_Full",   basePrice=10, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.PigletLeather_Landrace_Full",basePrice=10, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.LambLeather_Full",           basePrice=10, tags={"Material", "Leather"}, stockRange={min=1, max=3} },
{ item="Base.RabbitLeather_Full",         basePrice=8,  tags={"Material", "Leather"}, stockRange={min=2, max=8} },
{ item="Base.RaccoonLeather_Grey_Full",   basePrice=8,  tags={"Material", "Leather"}, stockRange={min=2, max=6} },

-- =============================================================================
-- 3. TROPHIES: HEADS (Decor / Biology)
-- =============================================================================
-- Rotting heads are cheap unless taxidermy is involved (assumed fresh here)

-- Livestock
{ item="Base.Bull_Head_Angus",          basePrice=10, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Bull_Head_Simmental",      basePrice=10, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Bull_Head_Holstein",       basePrice=10, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Cow_Head_Angus",           basePrice=8,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Cow_Head_Simmental",       basePrice=8,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Cow_Head_Holstein",        basePrice=8,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Boar_Head_Black",      basePrice=8,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Boar_Head_Pink",       basePrice=8,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Sow_Head_Black",       basePrice=6,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Sow_Head_Pink",        basePrice=6,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Ram_Head_White",     basePrice=8,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Ram_Head_Black",     basePrice=8,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },

-- Wild Game
{ item="Base.Deer_Buck_Head",           basePrice=20, tags={"Material", "Trophy", "Rare"}, stockRange={min=0, max=1} }, -- Impressive rack
{ item="Base.Deer_Doe_Head",            basePrice=8,  tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Raccoon_Boar_Head",        basePrice=5,  tags={"Material", "Trophy"}, stockRange={min=0, max=2} },
{ item="Base.Raccoon_Sow_Head",         basePrice=5,  tags={"Material", "Trophy"}, stockRange={min=0, max=2} },

-- Small/Juvenile Heads (Junk mostly)
{ item="Base.Calf_Head_Angus",          basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Calf_Head_Holstein",       basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Calf_Head_Simmental",      basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Deer_Fawn_Head",           basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Piglet_Head_Pink",     basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Piglet_Head_Black",    basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Lamb_Head_White",    basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Lamb_Head_Black",    basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },

-- Poultry Heads
{ item="Base.Chicken_Rooster_Head_White", basePrice=1, tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Chicken_Rooster_Head_Brown", basePrice=1, tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Chicken_Hen_Brown_Head",     basePrice=1, tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Chicken_Hen_White_Head",     basePrice=1, tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Turkey_Gobbler_Head",        basePrice=2, tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=3} },
{ item="Base.Turkey_Hen_Head",            basePrice=2, tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=3} },

-- =============================================================================
-- 4. TROPHIES: SKULLS (Permanent Decor)
-- =============================================================================
{ item="Base.Bull_Skull",               basePrice=15, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Cow_Skull",                basePrice=12, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.DeerStag_Skull",           basePrice=25, tags={"Material", "Trophy", "Rare"}, stockRange={min=0, max=1} },
{ item="Base.DeerDoe_Skull",            basePrice=10, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Ram_Skull",                basePrice=12, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Sheep_Skull",              basePrice=10, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },
{ item="Base.Pig_Skull",                basePrice=10, tags={"Material", "Trophy"}, stockRange={min=0, max=1} },

-- Small Skulls
{ item="Base.Calf_Skull",               basePrice=3,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Piglet_Skull",             basePrice=3,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Lamb_Skull",               basePrice=3,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.DeerFawn_Skull",           basePrice=3,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=1} },
{ item="Base.Raccoon_Skull",            basePrice=3,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=2} },
{ item="Base.Rabbit_Skull",             basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=3} },
{ item="Base.Chicken_Rooster_Skull",    basePrice=1,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Chicken_Hen_Skull",        basePrice=1,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=5} },
{ item="Base.Turkey_Skull",             basePrice=2,  tags={"Material", "Trophy", "Junk"}, stockRange={min=0, max=2} },

-- =============================================================================
-- 5. BONES & BYPRODUCTS
-- =============================================================================
{ item="Base.AnimalBone",           basePrice=1,   tags={"Material", "Bone"}, stockRange={min=5, max=20} },
{ item="Base.LargeAnimalBone",      basePrice=3,   tags={"Material", "Bone"}, stockRange={min=2, max=10} },
{ item="Base.SmallAnimalBone",      basePrice=0.5, tags={"Material", "Bone", "Junk"}, stockRange={min=5, max=30} },
{ item="Base.SharpBoneFragment",    basePrice=0.5, tags={"Material", "Bone", "Junk"}, stockRange={min=5, max=30} },
{ item="Base.AnimalSinew",          basePrice=2,   tags={"Material", "Medical"}, stockRange={min=2, max=10} }, -- Useful for stitching
{ item="Base.Animal_Brain",         basePrice=2,   tags={"Material", "Food"}, stockRange={min=1, max=5} }, -- Edible if desperate
{ item="Base.Animal_Brain_Small",   basePrice=1,   tags={"Material", "Food"}, stockRange={min=1, max=5} },
{ item="Base.ChickenFeather",       basePrice=0.1, tags={"Material", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.TurkeyFeather",        basePrice=0.1, tags={"Material", "Junk"}, stockRange={min=10, max=50} },
{ item="Base.ChickenFoot",          basePrice=1,   tags={"Material", "Junk", "Food"}, stockRange={min=2, max=10} },
{ item="Base.HerbivoreTeeth",       basePrice=0.1, tags={"Material", "Junk"}, stockRange={min=1, max=10} },
{ item="Base.PigTusk",              basePrice=2,   tags={"Material", "Trophy"}, stockRange={min=1, max=5} },
{ item="Base.JawboneBovide",        basePrice=2,   tags={"Material", "Bone"}, stockRange={min=1, max=5} },

-- =============================================================================
-- 6. PRIMITIVE WEAPONS (Bone Crafted)
-- =============================================================================
{ item="Base.BoneClub",             basePrice=5,   tags={"Weapon", "Melee", "Junk"}, stockRange={min=1, max=3} },
{ item="Base.BoneClub_Spiked",      basePrice=8,   tags={"Weapon", "Melee", "Junk"}, stockRange={min=1, max=3} },
{ item="Base.LargeBoneClub",        basePrice=8,   tags={"Weapon", "Melee", "Junk"}, stockRange={min=1, max=3} },
{ item="Base.LargeBoneClub_Spiked", basePrice=12,  tags={"Weapon", "Melee", "Junk"}, stockRange={min=1, max=3} },
})

print("[DynamicTrading] Animal Products Registry Complete.")
