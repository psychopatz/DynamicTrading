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

-- 1. BANDAGES & DRESSINGS
RegisterMedical({"Heal"}, {
    { item="Base.BandAid",     price=8,  min=5, max=15, id="BuyBandAid" },
    { item="Base.Bandage",     price=20, min=3, max=10, tags={"Clean"}, id="BuyBandageSterile" },
    { item="Base.CottonBalls", price=5,  min=5, max=15, tags={"Clean"} },
})

-- 2. DISINFECTANTS & CLEANING
RegisterMedical({"Clean"}, {
    { item="Base.Disinfectant",  price=45, min=1, max=4 },
    { item="Base.AlcoholWipes",  price=12, min=4, max=12 },
})

-- 3. MEDICATIONS & PILLS
RegisterMedical({}, {
    { item="Base.Antibiotics",      price=120, min=0, max=2, tags={"Rare"} },
    { item="Base.Painkillers",      price=30,  min=2, max=6 },
    { item="Base.BetaBlockers",     price=35,  min=1, max=5, tags={"Gun"} },
    { item="Base.Antidepressants",  price=40,  min=1, max=4 },
    { item="Base.SleepingTablets",  price=25,  min=1, max=4 },
    { item="Base.Vitamins",         price=15,  min=2, max=8, tags={"Food"} },
})

-- 4. SURGICAL TOOLS
RegisterMedical({"Heal"}, {
    { item="Base.SutureNeedle",       price=40, min=1, max=5 },
    { item="Base.SutureNeedleHolder", price=55, min=0, max=2 },
    { item="Base.Tweezers",           price=30, min=1, max=3 },
})

-- 5. SPECIALTY MEDICAL
RegisterMedical({"Heal"}, {
    { item="Base.FirstAidKit", price=60, min=0, max=2 },
    { item="Base.ColdPack",    price=20, min=1, max=4 },
    { item="Base.Splint",      price=25, min=1, max=3 },
})