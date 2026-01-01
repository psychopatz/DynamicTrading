require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterUtility(items)
    for _, config in ipairs(items) do
        -- Extract item name for the ID (e.g., "Hammer" from "Base.Hammer")
        local itemName = config.item:match(".*%.(.*)") or config.item
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

-- 1. TOOLS
RegisterUtility({
    { item="Base.Hammer",       price=15,  min=2, max=5, tags={"Build", "Essential"}, category="Tool" },
    { item="Base.Saw",          price=20,  min=1, max=4, tags={"Build", "Essential"}, category="Tool" },
    { item="Base.Screwdriver",  price=8,   min=3, max=8, tags={"Build", "Electric"},  category="Tool" },
    { item="Base.Sledgehammer", price=200, min=0, max=1, tags={"Build", "Heavy", "Rare"}, category="Tool" },
})

-- 2. GARDENING / FARMING
RegisterUtility({
    { item="Base.HandShovel",       price=12, min=1, max=4,  tags={"Crop"}, category="Gardening", id="BuyTrowel" },
    { item="farming.CarrotBagSeed", price=5,  min=5, max=15, tags={"Crop", "Food"}, category="Gardening", id="BuyCarrotSeeds" },
})

-- 3. CAMPING & FIRE
RegisterUtility({
    { item="camping.CampingTentKit", price=60, min=0, max=2,  tags={"Survival"}, category="Camping", id="BuyTentKit" },
    { item="Base.Lighter",           price=4,  min=5, max=15, tags={"Survival", "Smoker"}, category="Fire source" },
})



-- ==========================================================
-- DYNAMIC TRADING: TOOLS, METALWORKING & CRAFTING
-- Inner Workings & Balancing:
-- 1. ENTRY & UTILITY: Bolt Cutters (150) and Crowbars (120) are priced for high 
--    utility. Crowbars are the gold standard for durability/entry.
-- 2. B42 SMITHING PROGRESSION: Tools like the Small Punch Set, Tongs, and 
--    Smithing Hammer are essential for the new tech tree, commanding professional prices.
-- 3. FORGED VARIANTS: Forged versions (B42) carry a "Professional" premium (approx 30-40%) 
--    over standard counterparts due to increased durability and effectiveness.
-- 4. SPECIALIZED TRADES: Masonry, Carpentry, and Tailoring tools are tagged 
--    specifically to appear in their respective merchant archetypes.
-- 5. PRIMITIVE/CRUDE: Crude Wooden Tongs and Saws are priced as low-tier 
--    alternatives for early-game survivalists.
-- ==========================================================

local function RegisterGeneralTool(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        DynamicTrading.AddItem("Buy" .. itemName, {
            item = config.item,
            category = "Material",
            tags = config.tags or {"Tool"},
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 4 }
        })
    end
end

-- 1. CONSTRUCTION & ENTRY TOOLS (Build / Mechanic Focus)
RegisterGeneralTool({
    { item="Base.BoltCutters",        price=150, min=0, max=1, tags={"Mechanic", "Heavy", "Build"} },
    { item="Base.Crowbar",            price=120, min=1, max=3, tags={"Build", "Weapon", "Heavy"} },
    { item="Base.CrowbarForged",      price=165, min=0, max=2, tags={"Build", "Smith", "Weapon"} },
    { item="Base.Hammer",             price=45,  min=2, max=5, tags={"Build", "Weapon"} }, -- Claw Hammer
    { item="Base.HammerForged",       price=65,  min=1, max=3, tags={"Build", "Smith"} },
    { item="Base.ClubHammer",         price=60,  min=1, max=3, tags={"Build", "Heavy", "Weapon"} },
    { item="Base.ClubHammerForged",   price=80,  min=1, max=2, tags={"Build", "Smith", "Heavy"} },
    { item="Base.HammerStone",        price=15,  min=2, max=4, tags={"Build", "Primitive"} },
})

-- 2. MECHANICAL & PLUMBING (Mechanic Focus)
RegisterGeneralTool({
    { item="Base.Wrench",             price=35,  min=2, max=5, tags={"Mechanic", "Car", "Weapon"} },
    { item="Base.PipeWrench",         price=55,  min=1, max=3, tags={"Mechanic", "Weapon", "Heavy"} },
    { item="Base.Ratchet",            price=65,  min=1, max=2, tags={"Mechanic", "Car"} },
    { item="Base.ViseGrips",          price=40,  min=1, max=3, tags={"Mechanic", "Smith"} },
    { item="Base.MetalworkingPliers", price=35,  min=1, max=4, tags={"Mechanic", "Smith"} },
})

-- 3. SMITHING & METALWORKING (Smith Focus)
RegisterGeneralTool({
    { item="Base.SmithingHammer",     price=70,  min=1, max=2, tags={"Smith", "Build"} },
    { item="Base.Tongs",              price=40,  min=1, max=3, tags={"Smith"} },
    { item="Base.SmallPunchSet",      price=55,  min=1, max=2, tags={"Smith", "Mechanic"} },
    { item="Base.MetalworkingPunch",  price=20,  min=2, max=5, tags={"Smith"} },
    { item="Base.MetalworkingChisel", price=35,  min=2, max=4, tags={"Smith", "Build"} },
    { item="Base.HeadingTool",        price=50,  min=0, max=2, tags={"Smith", "Rare"} },
    { item="Base.SheetMetalSnips",    price=45,  min=1, max=3, tags={"Smith", "Mechanic"} },
    { item="Base.SmallFileSet",       price=45,  min=1, max=2, tags={"Smith", "Mechanic"} },
    { item="Base.File",               price=15,  min=2, max=6, tags={"Smith", "Mechanic"} },
})

-- 4. CARPENTRY, MASONRY & OTHER TRADES (Carpenter / Mason / Butcher)
RegisterGeneralTool({
    { item="Base.CrudeSaw",           price=20,  min=1, max=3, tags={"Carpenter", "Build", "Primitive"} },
    { item="Base.SmallSaw",           price=45,  min=1, max=3, tags={"Carpenter", "Mechanic", "Build"} }, -- Hacksaw
    { item="Base.CarpentryChisel",    price=30,  min=1, max=4, tags={"Carpenter", "Build"} },
    { item="Base.MasonsTrowel",       price=35,  min=1, max=3, tags={"Mason", "Build"} },
    { item="Base.MasonsChisel",       price=35,  min=1, max=3, tags={"Mason", "Build"} },
    { item="Base.Fleshing_Tool",      price=25,  min=1, max=2, tags={"Butcher", "Leatherworker"} },
})

-- 5. SMALL TOOLS & TAILORING (Tailor / General)
RegisterGeneralTool({
    { item="Base.Needle",               price=15,  min=2, max=8, tags={"Tailor", "Survival"} },
    { item="Base.Needle_Forged",        price=25,  min=1, max=3, tags={"Tailor", "Smith"} },
    { item="Base.KnifePocket",          price=20,  min=2, max=6, tags={"Survival", "Weapon"} },
    { item="Base.SmallKnife",           price=25,  min=2, max=5, tags={"Survival", "Weapon", "Blade"} },
    { item="Base.CompassGeometry",      price=15,  min=1, max=2, tags={"Literature", "Mechanic"} },
    { item="Base.FireplacePoker",       price=30,  min=1, max=3, tags={"Weapon", "Junk"} },
    { item="Base.HandFork",             price=15,  min=1, max=4, tags={"Gardening", "Weapon"} },
    { item="Base.LargeHook",            price=25,  min=1, max=3, tags={"Butcher", "Junk"} },
    { item="Base.BallPeenHammer",       price=40,  min=2, max=5, tags={"Mechanic", "Weapon"} },
    { item="Base.BallPeenHammerForged", price=55,  min=1, max=3, tags={"Smith", "Mechanic"} },
    { item="Base.CrudeWoodenTongs",     price=10,  min=1, max=3, tags={"Smith", "Primitive"} },
})


-- ==========================================================
-- DYNAMIC TRADING: CRAFTING TOOLS & SMITHING EQUIPMENT
-- Inner Workings & Balancing:
-- 1. UTILITY: The Multitool is the "Gold Standard" of survival gear, priced at a 
--    premium (120) for its space-saving utility and rarity.
-- 2. SMITHING PROGRESSION: Essential B42 smithing tools like the Small Punch Set, 
--    Heading Tool, and Smithing Hammer are priced mid-to-high (45-60) as they 
--    gatekeep advanced metalworking.
-- 3. PRIMITIVE VS INDUSTRIAL: Bone and Stone variants (Awls/Needles) are the 
--    cheapest "starter" tier. Forged and Brass variants command higher prices 
--    for durability and professional use.
-- 4. MERCHANT TAGS:
--    - "Smith": Core metalworking tools for the Carpenter/Mechanic archetypes.
--    - "Tailor": Needles and Awls for clothing repair.
--    - "Build": General construction hammers.
--    - "Mechanic": Utility tools like Vise Grips and Pliers.
--    - "Primitive": Low-tier crafted bone/stone tools.
-- ==========================================================

-- 1. HEAVY TOOLS & HAMMERS (Build / Smith Focus)
RegisterAmmo({"Tool"}, {
    { item="Base.SmithingHammer",       price=60,  min=1, max=3, tags={"Smith", "Build", "Weapon", "Heavy"} },
    { item="Base.BallPeenHammer",       price=40,  min=2, max=5, tags={"Build", "Mechanic", "Weapon"} },
    { item="Base.BallPeenHammerForged", price=55,  min=1, max=3, tags={"Smith", "Build", "Weapon"} },
})

-- 2. SMITHING & METALWORKING SPECIALTY (Smith Focus)
RegisterAmmo({"Tool"}, {
    { item="Base.SmallPunchSet",        price=55,  min=1, max=2, tags={"Smith", "Mechanic"} },
    { item="Base.HeadingTool",          price=45,  min=1, max=2, tags={"Smith"} },
    { item="Base.Tongs",                price=40,  min=1, max=3, tags={"Smith"} },
    { item="Base.ViseGrips",            price=38,  min=1, max=4, tags={"Mechanic", "Smith"} },
    { item="Base.MetalworkingPliers",   price=35,  min=2, max=5, tags={"Mechanic", "Smith"} },
    { item="Base.MetalworkingPunch",    price=15,  min=2, max=6, tags={"Smith"} },
})

-- 3. TAILORING & LEATHERWORK (Tailor Focus)
RegisterAmmo({"Tool"}, {
    { item="Base.Needle_Forged",        price=25,  min=1, max=3, tags={"Tailor", "Smith"} },
    { item="Base.Needle",               price=15,  min=2, max=8, tags={"Tailor"} },
    { item="Base.Needle_Brass",         price=12,  min=2, max=6, tags={"Tailor"} },
    { item="Base.Needle_Bone",          price=4,   min=3, max=10,tags={"Tailor", "Primitive"} },
    { item="Base.Awl",                  price=15,  min=1, max=4, tags={"Tailor"} },
    { item="Base.Awl_Stone",            price=6,   min=2, max=5, tags={"Tailor", "Primitive"} },
    { item="Base.Awl_Bone",             price=5,   min=2, max=5, tags={"Tailor", "Primitive"} },
})

-- 4. SURVIVAL & MULTI-PURPOSE
RegisterAmmo({"Tool"}, {
    { item="Base.Multitool",            price=120, min=0, max=1, tags={"Mechanic", "Survival", "Rare"} },
    { item="Base.Handiknife",           price=30,  min=1, max=4, tags={"Survival", "Weapon", "Blade"} },
})