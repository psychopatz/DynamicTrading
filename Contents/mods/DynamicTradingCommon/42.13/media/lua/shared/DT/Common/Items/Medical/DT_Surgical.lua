-- =============================================================================
-- DYNAMIC TRADING: MEDICAL - SURGICAL
-- =============================================================================
-- Root Category: Medical
-- Sub Category: Surgical
-- =============================================================================

require "DT/Common/Config" 
if not DynamicTrading then return end

DynamicTrading.RegisterBatch({
    { item="Base.CeramicMortarandPestle",basePrice=60,tags={"Medical.Surgical.Tool", "Quality.Luxury"}, stockRange={min=1, max=5} },
    { item="Base.Forceps_Forged",       basePrice=150, tags={"Medical.Surgical.Tool", "Origin.Healthcare"}, stockRange={min=1, max=5} },
    { item="Base.MortarPestle",         basePrice=40, tags={"Medical.Surgical.Tool", "Theme.Survival"}, stockRange={min=1, max=5} },
    { item="Base.Scalpel",              basePrice=130, tags={"Medical.Surgical.Tool", "Origin.Healthcare"}, stockRange={min=1, max=5} },
    { item="Base.ScissorsBluntMedical", basePrice=80,  tags={"Medical.Surgical.Tool", "Origin.Medical"}, stockRange={min=1, max=10} }, -- Medical Shears -- Medical Shears,
    { item="Base.SutureNeedle",         basePrice=75,  tags={"Medical.Surgical.Tool", "Quality.Sterile"}, stockRange={min=2, max=12} }, -- Scale 50-150,
    { item="Base.SutureNeedleBox",      basePrice=300, tags={"Medical.Surgical.Tool", "Quality.Sterile"}, stockRange={min=0, max=2} },
    { item="Base.SutureNeedleHolder",   basePrice=110, tags={"Medical.Surgical.Tool", "Origin.Healthcare"}, stockRange={min=1, max=5} },
    { item="Base.Tweezers",             basePrice=50,  tags={"Medical.Surgical.Tool", "Rarity.Common"}, stockRange={min=2, max=10} },
    { item="Base.Tweezers_Forged",      basePrice=90,  tags={"Medical.Surgical.Tool", "Origin.Healthcare"}, stockRange={min=1, max=5} },
})

print("[DynamicTrading] Medical/Surgical Registry Loaded.")
