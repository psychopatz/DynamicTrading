require "DynamicTrading_Config"

if not DynamicTrading then return end

-- ==========================================================
-- HELPER FUNCTION
-- ==========================================================
local function RegisterMisc(items)
    for _, config in ipairs(items) do
        local itemName = config.item:match(".*%.(.*)") or config.item
        local uniqueID = config.id or ("Buy" .. itemName)

        DynamicTrading.AddItem(uniqueID, {
            item = config.item,
            category = config.category or "Misc",
            tags = config.tags or {},
            basePrice = config.price,
            stockRange = { min = config.min or 1, max = config.max or 5 }
        })
    end
end

-- ==========================================================
-- ITEM DEFINITIONS (Compressed)
-- ==========================================================

RegisterMisc({
    { item="Base.ScrapMetal", price=5, min=5, max=20, tags={"Metal"}, category="Material" },
    { item="Base.RubberDuck", price=2, min=1, max=1,  tags={"Toy"},   category="Junk" },
})