require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterGear(category, commonTags, items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        local uniqueID = config.id or ("Buy" .. itemName)

        local finalTags = {}
        if commonTags then for _, t in ipairs(commonTags) do table.insert(finalTags, t) end end
        if config.tags then for _, t in ipairs(config.tags) do table.insert(finalTags, t) end end

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = category,
            tags = finalTags,
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 3 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Compressed)
-- ==========================================================

-- 1. BAGS & CONTAINERS
RegisterGear("Container", {"Gear"}, {
    { item="Base.Bag_Schoolbag",    price=250, min=1, max=3, id="BuySchoolBag" },
    { item="Base.Bag_DuffelBag",    price=500, min=1, max=2, id="BuyDuffelBag" },
    { item="Base.Bag_BigHikingBag", price=800, min=0, max=1, tags={"Rare"}, id="BuyBigHikingBag" },
})

-- 2. CLOTHING & WEARABLES
RegisterGear("Clothing", {}, {
    { item="Base.JacketLong_Random", price=40,  min=1, max=2, tags={"Warm", "Armor"}, id="BuyLeatherJacket" },
    { item="Base.Shoes_ArmyBoots",   price=350, min=1, max=3, tags={"Armor"}, id="BuyMilitaryBoots" },
    { item="Base.Hat_Beanie",        price=10,  min=2, max=5, tags={"Warm"}, id="BuyWinterHat" },
    { item="Base.PonchoYellow",      price=15,  min=1, max=3, tags={"Rain"}, id="BuyPoncho" },
})