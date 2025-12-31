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