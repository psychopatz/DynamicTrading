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

-- 3. VEHICLE PARTS & TOOLS
RegisterMaintenance({
    { item="Base.CarBattery1", price=80, min=0, max=2, tags={"Car", "Electric", "Heavy"}, category="Vehicle part", id="BuyCarBattery" },
    { item="Base.Wrench",      price=18, min=1, max=3, tags={"Car", "Tool"}, category="Tool" },
})