-- =============================================================================
-- DYNAMIC TRADING: FOOD - MEAT
-- =============================================================================
-- Root Category: Food
-- Sub Category: Meat
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.Animal_Brain",         basePrice=10,  tags={"Food.Meat.Perishable", "Theme.Survival"}, stockRange={min=1, max=5} }, -- Edible if desperate,
    { item="Base.Animal_Brain_Small",   basePrice=5,   tags={"Food.Meat.Perishable", "Theme.Survival"}, stockRange={min=1, max=5} },
    { item="Base.ChickenFoot",          basePrice=2,   tags={"Food.Meat.Perishable", "Quality.Waste"}, stockRange={min=2, max=10} },
    { item="Base.DeadMousePupsSkinned", basePrice=1, tags={"Food.Meat.Perishable", "Theme.Survival", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.DeadMouseSkinned",     basePrice=2, tags={"Food.Meat.Perishable", "Theme.Survival", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.DeadRatBabySkinned",   basePrice=1, tags={"Food.Meat.Perishable", "Theme.Survival", "Quality.Waste"}, stockRange={min=1, max=5} },
    { item="Base.DeadRatSkinned",       basePrice=3, tags={"Food.Meat.Perishable", "Theme.Survival", "Quality.Waste"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Food/Meat Registry Loaded.")
