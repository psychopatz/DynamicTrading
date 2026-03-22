-- =============================================================================
-- 5. GAMEPLAY HELPERS
-- =============================================================================
function DynamicTrading.Config.GetRadioData(itemFullType)
    return DynamicTrading.Config.RadioTiers[itemFullType] or { power = 0.5, desc = "Unknown Device" }
end

function DynamicTrading.Config.GetDifficultyData()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    return {
        name        = "Custom Sandbox",
        buyMult     = sandbox.PriceBuyMult or 1.0,
        sellMult    = sandbox.PriceSellMult or 0.5,
        stockMult   = sandbox.StockMult or 1.0,
        rarityBonus = sandbox.RarityBonus or 0
    }
end
