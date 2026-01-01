require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterMaintenance(items)
    for _, config in ipairs(items) do
        -- Extract "NailsBox" from "Base.NailsBox"
        local itemName = config.item:match(".*%.(.*)") or config.item
        
        -- Use provided id, otherwise auto-generate "Buy" + "NailsBox"
        local uniqueID = config.id or ("Buy" .. itemName)

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = config.category,
            tags = config.tags or {},
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 5 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Compressed)
-- ==========================================================

-- 1. BASIC MATERIALS
RegisterMaintenance({
    { item="Base.NailsBox", price=15, min=5, max=20, tags={"Build"}, category="Material" },
    { item="Base.Woodglue", price=12, min=2, max=8,  tags={"Build"}, category="Material", id="BuyWoodGlue" },
    { item="Base.DuctTape", price=12, min=3, max=10, tags={"Build", "Repair"}, category="Material" },
})

-- 2. FUEL
RegisterMaintenance({
    { item="Base.PetrolCan",   price=45, min=2, max=6, tags={"Fuel"}, category="Fuel" },
    { item="Base.PropaneTank", price=60, min=1, max=4, tags={"Fuel", "Heavy"}, category="Fuel" },
})

-- ==========================================================
-- DYNAMIC TRADING: UNPROCESSED ANIMAL HIDES
-- Inner Workings & Balancing:
-- 1. MATERIAL YIELD: Large hides (Cow, Bull) are priced highest (65+) because 
--    they provide significantly more leather/scraps than small animal hides.
-- 2. WEIGHT PENALTY: Large hides (5.0 weight) carry a price premium to 
--    compensate for the difficulty of transporting them to a merchant.
-- 3. MERCHANT TAGS:
--    - "Butcher": Primary buyer/seller of raw animal parts and hides.
--    - "Leatherworker": Specialized tag for high-volume hide trading.
--    - "Hunter": Wild game hides like Deer, Fawn, Rabbit, and Raccoon.
--    - "Farmer": Domesticated livestock hides (Cow, Pig, Sheep).
-- 4. STOCK RANGE: Set to lower values (1-4) to simulate the rarity of 
--    pristine unprocessed skins in the field.
-- ==========================================================

local function RegisterHide(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        DynamicTrading.AddItem("Buy" .. itemName, {
            item = config.item,
            category = "Material",
            tags = config.tags or {"Hide", "Leather"},
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 4 }
        })
    end
end

-- 1. LARGE DOMESTIC HIDES (Cow & Bull - High Yield)
RegisterHide({
    { item="Base.CowLeather_Angus_Full",     price=75, tags={"Farmer", "Butcher", "Leatherworker", "Heavy"} },
    { item="Base.CowLeather_Holstein_Full",  price=75, tags={"Farmer", "Butcher", "Leatherworker", "Heavy"} },
    { item="Base.CowLeather_Simmental_Full", price=75, tags={"Farmer", "Butcher", "Leatherworker", "Heavy"} },
})

-- 2. MEDIUM DOMESTIC & WILD HIDES (Pig, Deer, Sheep)
RegisterHide({
    { item="Base.PigLeather_Black_Full",     price=45, tags={"Farmer", "Butcher", "Leatherworker"} },
    { item="Base.PigLeather_Landrace_Full",  price=45, tags={"Farmer", "Butcher", "Leatherworker"} },
    { item="Base.DeerLeather_Full",          price=50, tags={"Hunter", "Butcher", "Leatherworker", "Rare"} },
    { item="Base.SheepLeather_Full",         price=40, tags={"Farmer", "Butcher", "Leatherworker"} },
})

-- 3. SMALL & JUVENILE HIDES (Calf, Piglet, Lamb, Fawn)
RegisterHide({
    { item="Base.CalfLeather_Angus_Full",     price=25, tags={"Farmer", "Butcher"} },
    { item="Base.CalfLeather_Holstein_Full",  price=25, tags={"Farmer", "Butcher"} },
    { item="Base.CalfLeather_Simmental_Full", price=25, tags={"Farmer", "Butcher"} },
    { item="Base.PigletLeather_Black_Full",   price=20, tags={"Farmer", "Butcher"} },
    { item="Base.PigletLeather_Landrace_Full", price=20, tags={"Farmer", "Butcher"} },
    { item="Base.LambLeather_Full",           price=20, tags={"Farmer", "Butcher"} },
    { item="Base.FawnLeather_Full",           price=22, tags={"Hunter", "Butcher"} },
})

-- 4. SMALL GAME HIDES (Rabbit & Raccoon)
RegisterHide({
    { item="Base.RabbitLeather_Full",         price=15, tags={"Hunter", "Scavenger", "SmallGame"} },
    { item="Base.RaccoonLeather_Grey_Full",   price=18, tags={"Hunter", "Scavenger", "SmallGame"} },
})

-- ==========================================================
-- DYNAMIC TRADING: TOOLS & WEAPONS (MELEE & UTILITY)
-- Inner Workings & Balancing:
-- 1. THE "SLEDGEHAMMER" TIER: Priced as a "Game-Ender" item (500). Its ability 
--    to destroy stairs and walls makes it the most valuable non-firearm tool.
-- 2. AXES & CHOPPING: Firefighter and Wood Axes are high-value (150-180) due 
--    to high damage and essential wood-gathering utility. "Old" versions are 
--    budget-friendly with lower durability.
-- 3. THE "FORGED" PREMIUM: Forged variants (B42) command a ~30% higher price 
--    over standard versions, representing superior craftsmanship and durability.
-- 4. BLADES: Machete knives and Large knives are mid-tier combat options. 
--    Pocket knives and Small knives are cheap, low-weight survival tools.
-- 5. MERCHANT TAGS:
--    - "Build": Sledgehammers, Claw Hammers, Wood Axes.
--    - "Weapon": High-damage items (Axes, Machetes, Sledges).
--    - "Blade": Knives, Machetes, Hatchets.
--    - "Heavy": Large tools requiring high strength (Sledges, Pickaxes).
--    - "Survival": Multitools, Handiknives, Pocket Knives.
--    - "Smith": Smithing hammers and Forged variants.
-- ==========================================================

local function RegisterToolWeapon(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        DynamicTrading.AddItem("Buy" .. itemName, {
            item = config.item,
            category = "Weapon",
            tags = config.tags or {"Tool", "Weapon"},
            basePrice = config.price,
            stockRange = { min = config.min or 0, max = config.max or 3 }
        })
    end
end

-- 1. HEAVY DESTRUCTION & EXCAVATION (High Value)
RegisterToolWeapon({
    { item="Base.Sledgehammer",       price=500, min=0, max=1, tags={"Build", "Heavy", "Rare", "Weapon", "Tool"} },
    { item="Base.Sledgehammer2",      price=500, min=0, max=1, tags={"Build", "Heavy", "Rare", "Weapon", "Tool"} },
    { item="Base.SledgehammerForged", price=650, min=0, max=1, tags={"Build", "Heavy", "Rare", "Smith", "Weapon"} },
    { item="Base.PickAxe",            price=140, min=1, max=2, tags={"Heavy", "Tool", "Weapon"} },
    { item="Base.PickAxeForged",      price=185, min=0, max=2, tags={"Heavy", "Smith", "Weapon"} },
})

-- 2. AXES & HATCHETS (Chopping & Combat)
RegisterToolWeapon({
    { item="Base.Axe",                price=180, min=1, max=3, tags={"Weapon", "Tool", "Blade", "Build"} }, -- Firefighter Axe
    { item="Base.WoodAxe",            price=160, min=1, max=2, tags={"Tool", "Build", "Heavy", "Weapon"} },
    { item="Base.WoodAxeForged",      price=210, min=0, max=2, tags={"Smith", "Build", "Heavy", "Weapon"} },
    { item="Base.Axe_Old",            price=90,  min=1, max=3, tags={"Tool", "Weapon", "Budget"} },
    { item="Base.HandAxe",            price=75,  min=2, max=5, tags={"Blade", "Survival", "Tool", "Weapon"} }, -- Hatchet
    { item="Base.HandAxeForged",      price=100, min=1, max=3, tags={"Smith", "Blade", "Weapon"} },
    { item="Base.HandAxe_Old",        price=45,  min=2, max=4, tags={"Survival", "Weapon", "Budget"} }, -- Hand Axe
})

-- 3. HAMMERS & MALLETS (Construction & Smithing)
RegisterToolWeapon({
    { item="Base.Hammer",             price=45,  min=2, max=6, tags={"Build", "Tool", "Weapon"} }, -- Claw Hammer
    { item="Base.HammerForged",       price=65,  min=1, max=4, tags={"Smith", "Build", "Tool"} },
    { item="Base.ClubHammer",         price=60,  min=1, max=3, tags={"Build", "Heavy", "Weapon"} },
    { item="Base.ClubHammerForged",   price=80,  min=1, max=2, tags={"Smith", "Heavy", "Weapon"} },
    { item="Base.BallPeenHammer",     price=40,  min=2, max=5, tags={"Mechanic", "Tool", "Weapon"} },
    { item="Base.BallPeenHammerForged", price=55, min=1, max=3, tags={"Smith", "Mechanic", "Tool"} },
    { item="Base.SmithingHammer",     price=70,  min=1, max=3, tags={"Smith", "Build", "Tool"} },
    { item="Base.HammerStone",        price=15,  min=2, max=5, tags={"Primitive", "Build", "Budget"} },
    { item="Base.WoodenMallet",       price=25,  min=2, max=5, tags={"Build", "Tool", "Weapon"} },
})

-- 4. KNIVES & BLADES (Survival & Stealth)
RegisterToolWeapon({
    { item="Base.MacheteKnife",       price=110, min=1, max=2, tags={"Blade", "Weapon", "Survival"} },
    { item="Base.LargeKnife",         price=55,  min=2, max=5, tags={"Blade", "Weapon", "Survival"} },
    { item="Base.LargeKnife_Scrap",   price=30,  min=2, max=4, tags={"Blade", "Scavenger", "Budget"} },
    { item="Base.SmallKnife",         price=25,  min=3, max=8, tags={"Blade", "Survival", "Tool"} },
    { item="Base.KnifePocket",        price=15,  min=4, max=10,tags={"Survival", "Tool", "Budget"} },
    { item="Base.Handiknife",         price=35,  min=2, max=5, tags={"Survival", "Tool", "Weapon"} },
})

-- 5. SPECIALTY UTILITY
RegisterToolWeapon({
    { item="Base.Multitool",          price=120, min=0, max=1, tags={"Mechanic", "Survival", "Rare", "Tool"} },
})