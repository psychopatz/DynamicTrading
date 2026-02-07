DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = DynamicTrading.Config or {}

function DynamicTrading.Config.GetRadioData(itemFullType)
    return DynamicTrading.Config.RadioTiers[itemFullType] or { power = 0.5, desc = "Unknown Device" }
end

-- =============================================================================
-- DIFFICULTY (Sandbox Driven)
-- =============================================================================
function DynamicTrading.Config.GetDifficultyData()
    -- Create the data object directly from Sandbox variables
    return {
        name        = "Custom Sandbox",
        buyMult     = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PriceBuyMult) or 1.0,
        sellMult    = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.PriceSellMult) or 0.5,
        stockMult   = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.StockMult) or 1.0,
        rarityBonus = (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.RarityBonus) or 0
    }
end

print("[DynamicTrading] Config Loaded.")

-- =============================================================================
-- ITEM DEFINITIONS (Unified)
-- =============================================================================
-- Basics & Survival
require "DT/Common/Items/DT_Food"
require "DT/Common/Items/DT_Cooking"
require "DT/Common/Items/DT_Camping"
require "DT/Common/Items/DT_Traps"             
require "DT/Common/Items/DT_AnimalProducts"  
-- Equipment
require "DT/Common/Items/DT_Clothing"
require "DT/Common/Items/DT_Appearance"        
require "DT/Common/Items/DT_Weapons"
require "DT/Common/Items/DT_Ammo"
require "DT/Common/Items/DT_Tools"
-- Medical & Tech
require "DT/Common/Items/DT_Medical"
require "DT/Common/Items/DT_Electronics"
-- Storage & Materials
require "DT/Common/Items/DT_Containers"        
require "DT/Common/Items/DT_ContainersFluid"   
require "DT/Common/Items/DT_Materials"
require "DT/Common/Items/DT_Fuel"             
-- Misc & Loot
require "DT/Common/Items/DT_Junk"
require "DT/Common/Items/DT_Luxury"
require "DT/Common/Items/DT_Household"
require "DT/Common/Items/DT_Literature"
require "DT/Common/Items/DT_Vehicle"
