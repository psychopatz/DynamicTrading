require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterMedical(commonTags, items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        local uniqueID = config.id or ("Buy" .. itemName)

        local finalTags = {"Medical"}
        if commonTags then for _, t in ipairs(commonTags) do table.insert(finalTags, t) end end
        if config.tags then for _, t in ipairs(config.tags) do table.insert(finalTags, t) end end

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = "Medical",
            tags = finalTags,
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 5 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Compressed)
-- ==========================================================
-- ==========================================================
-- DYNAMIC TRADING: MEDICAL BANDAGES & WOUND CARE
-- Inner Workings & Balancing:
-- 1. STERILIZATION PREMIUM: Sterilized bandages (AlcoholBandage) are top-tier. 
--    They actively fight infection and have a high recovery power, commanding a high price.
-- 2. PROFESSIONAL VS IMPROVISED: Medical-grade bandages are significantly 
--    more effective than Ripped Sheets or Denim Strips, reflected in the 4x price gap.
-- 3. WEIGHT & CONVENIENCE: Adhesive Bandages (Bandaids) are priced for their 
--    extremely low weight (0.05), making them ideal for carrying in bulk.
-- 4. DIRTY ITEMS: Dirty rags and bandages are "Junk" tier. They carry a massive 
--    infection risk, priced at a near-worthless floor (1-2 credits).
-- 5. MERCHANT TAGS:
--    - "Medical": Professional grade equipment (Pharmacist/Gunrunner).
--    - "Heal": Core items used for wound recovery.
--    - "Survival": Improvised or field-expedient gear (Survivalist/Scavenger).
--    - "Clean": Sterilized items.
-- ==========================================================

local function RegisterMedical(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        DynamicTrading.AddItem("Buy" .. itemName, {
            item = config.item,
            category = "Medical",
            tags = config.tags or {"Medical"},
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 8 }
        })
    end
end

-- 1. PROFESSIONAL GRADE (Pharmacist / High-Tier)
RegisterMedical({
    { item="Base.AlcoholBandage",     price=55, tags={"Medical", "Heal", "Clean", "Rare"}, min=1, max=4 },
    { item="Base.Bandage",            price=30, tags={"Medical", "Heal"} },
    { item="Base.Bandaid",            price=12, tags={"Medical", "Heal", "Survival"} },
})
RegisterMedical({
    -- Multi-use bottle (The standard)
    { item="Base.Disinfectant",           price=45, min=2, max=6, tags={"Pharmacist", "Clean", "Heal"} },
    
    -- Single-use High Power (Convenience items)
    { item="Base.AlcoholWipes",           price=25, min=3, max=10, tags={"Pharmacist", "Survivalist", "Clean"} },
    { item="Base.AlcoholedCottonBalls",   price=18, min=5, max=15, tags={"Pharmacist", "Survivalist", "Clean", "Heal"} },
})

-- 2. IMPROVISED CLEAN (Survivalist / Scavenger)
RegisterMedical({
    { item="Base.AlcoholRippedSheets", price=20, tags={"Medical", "Survival", "Clean"} },
    { item="Base.RippedSheets",        price=5,  tags={"Survival", "Heal"} },
    { item="Base.DenimStrips",         price=8,  tags={"Survival", "Material"} },
    { item="Base.LeatherStrips",       price=10, tags={"Survival", "Material"} },
})

-- 3. DIRTY / JUNK (Emergency Only)
RegisterMedical({
    { item="Base.BandageDirty",        price=2,  tags={"Medical", "Junk"}, min=0, max=5 },
    { item="Base.RippedSheetsDirty",   price=1,  tags={"Survival", "Junk"}, min=0, max=10 },
    { item="Base.DenimStripsDirty",    price=2,  tags={"Survival", "Junk"}, min=0, max=5 },
    { item="Base.LeatherStripsDirty",  price=2,  tags={"Survival", "Junk"}, min=0, max=5 },
})

-- ==========================================================
-- DYNAMIC TRADING: COMPREHENSIVE MEDICAL & HERBAL DEFINITIONS
-- Inner Workings & Balancing:
-- 1. LIFE-SAVING PREMIUM: Antibiotics and Suture Needles are high-priced. 
--    They represent the difference between life and death for wound infections/deep wounds.
-- 2. TOOL REUSABILITY: Reusable tools (Tweezers, Forceps, Mortar and Pestle) 
--    command a higher base price than consumables.
-- 3. HERBAL LOGIC: Fresh herbs are cheaper but perishable. Dried herbs 
--    are priced for long-term survival security.
-- 4. BULK DISCOUNT: Boxes of supplies are priced at ~80% of the individual item total.
-- 5. MERCHANT TAGS:
--    - "Pharmacist": Pills and standard medicine.
--    - "Surgeon": High-end tools (Scalpel, Suture Holder, Pro Kits).
--    - "Herbalist": Medicinal plants and Mortar/Pestle.
--    - "Heal": Core recovery items (Bandages, Splints).
--    - "Clean": Antiseptics and sterilized supplies.
-- ==========================================================

local function RegisterMedical(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        DynamicTrading.AddItem(config.id or ("Buy" .. itemName), {
            item = config.item,
            category = "Medical",
            tags = config.tags or {"Medical"},
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 5 }
        })
    end
end

-- 1. MEDICINAL HERBS (Herbalist / Survivalist)
RegisterMedical({
    { item="Base.BlackSage",      price=15, tags={"Herbalist", "Medical", "Heal"} },
    { item="Base.BlackSageDried", price=25, tags={"Herbalist", "Medical", "Heal", "Rare"} },
    { item="Base.CommonMallow",      price=12, tags={"Herbalist", "Medical"} },
    { item="Base.CommonMallowDried", price=20, tags={"Herbalist", "Medical", "Rare"} },
    { item="Base.WildGarlic2",       price=22, tags={"Herbalist", "Medical", "Clean"} },
    { item="Base.WildGarlicDried",   price=35, tags={"Herbalist", "Medical", "Clean", "Rare"} },
    { item="Base.Comfrey",           price=18, tags={"Herbalist", "Medical", "Heal"} },
    { item="Base.ComfreyDried",      price=30, tags={"Herbalist", "Medical", "Heal", "Rare"} },
    { item="Base.Plantain",          price=18, tags={"Herbalist", "Medical", "Heal"} },
    { item="Base.PlantainDried",     price=30, tags={"Herbalist", "Medical", "Heal", "Rare"} },
    { item="Base.Ginseng",           price=25, tags={"Herbalist", "Medical", "Survivalist"} },
})

-- 2. PHARMACEUTICALS (Pharmacist / Gunrunner)
RegisterMedical({
    { item="Base.Antibiotics",      price=120, tags={"Pharmacist", "Heal", "Rare"}, min=0, max=2 },
    { item="Base.PillsAntiDep",     price=40,  tags={"Pharmacist", "Heal"} },
    { item="Base.PillsBeta",        price=45,  tags={"Pharmacist", "Gunrunner", "Heal"} },
    { item="Base.PillsVitamins",    price=50,  tags={"Pharmacist", "Survivalist", "Heal"} }, -- Caffeine Pills
    { item="Base.Pills",            price=30,  tags={"Pharmacist", "Survivalist", "Heal"} }, -- Painkillers
    { item="Base.PillsSleepingTablets", price=25, tags={"Pharmacist", "Heal"} },
})

-- 3. SURGICAL TOOLS & EQUIPMENT (Surgeon / Doctor)
RegisterMedical({
    { item="Base.SutureNeedle",       price=35, tags={"Surgeon", "Medical", "Heal"} },
    { item="Base.SutureNeedleHolder", price=75, tags={"Surgeon", "Medical", "Rare"} }, -- Forceps
    { item="Base.Forceps_Forged",     price=60, tags={"Surgeon", "Medical", "Repair"} },
    { item="Base.Scalpel",            price=50, tags={"Surgeon", "Medical", "Blade"} },
    { item="Base.ScissorsBluntMedical", price=35, tags={"Surgeon", "Medical"} },
    { item="Base.Tweezers",           price=25, tags={"Surgeon", "Medical", "Survivalist"} },
    { item="Base.Tweezers_Forged",    price=20, tags={"Surgeon", "Medical"} },
    { item="Base.Stethoscope",        price=45, tags={"Surgeon", "Medical", "Rare"} },
    { item="Base.MortarPestle",       price=55, tags={"Herbalist", "Medical"} },
    { item="Base.CeramicMortarandPestle", price=65, tags={"Herbalist", "Medical", "Rare"} },
})

-- 4. FIRST AID KITS & SPLINTS
RegisterMedical({
    { item="Base.FirstAidKit",        price=150, tags={"Medical", "Survivalist", "Heal"}, min=0, max=2 },
    { item="Base.FirstAidKit_New",    price=180, tags={"Medical", "Surgeon", "Heal"}, min=0, max=2 },
    { item="Base.FirstAidKit_NewPro", price=250, tags={"Medical", "Surgeon", "Rare"}, min=0, max=1 },
    { item="Base.Splint",             price=40,  tags={"Medical", "Survivalist", "Heal"} },
})

-- 5. CONSUMABLE SUPPLIES & CLOTHING
RegisterMedical({
    { item="Base.Coldpack",           price=15, tags={"Medical", "Survivalist"} },
    { item="Base.CottonBalls",        price=10, tags={"Medical", "Clean"} },
    { item="Base.TongueDepressor",    price=5,  tags={"Medical"} },
    { item="Base.Tissue",             price=8,  tags={"General", "Clean"} },
    { item="Base.Hat_SurgicalMask",   price=20, tags={"Medical", "Surgeon", "Clothing"} },
    { item="Base.Hat_SurgicalCap",    price=15, tags={"Medical", "Surgeon", "Clothing"} },
    { item="Base.Gloves_Surgical",    price=25, tags={"Medical", "Surgeon", "Clothing"} },
})

-- 6. BULK MEDICAL BOXES (High Tier Traders)
RegisterMedical({
    { item="Base.AntibioticsBox",      price=500, tags={"Pharmacist", "Rare", "Bulk"}, min=0, max=1 },
    { item="Base.BandageBox",          price=180, tags={"Medical", "Heal", "Bulk"},    min=1, max=3 },
    { item="Base.AdhesiveBandageBox",  price=100, tags={"Medical", "Heal", "Bulk"},    min=1, max=3 },
    { item="Base.SutureNeedleBox",     price=280, tags={"Surgeon", "Heal", "Bulk"},    min=0, max=1 },
    { item="Base.ColdpackBox",         price=120, tags={"Medical", "Bulk"},            min=0, max=2 },
    { item="Base.CottonBallsBox",      price=80,  tags={"Medical", "Bulk"},            min=1, max=3 },
    { item="Base.TissueBox",           price=70,  tags={"General", "Bulk"},            min=1, max=3 },
    { item="Base.TongueDepressorBox",  price=40,  tags={"Medical", "Bulk"},            min=0, max=2 },
})