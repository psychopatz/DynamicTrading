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
