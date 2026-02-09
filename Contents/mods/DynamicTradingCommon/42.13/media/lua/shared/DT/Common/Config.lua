DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = DynamicTrading.Config or {}

-- [RESTORED] We go back to using "MasterList" because your Economy/Manager systems rely on it.
DynamicTrading.Config.MasterList = DynamicTrading.Config.MasterList or {}

-- 1. The Single Item Adder
function DynamicTrading.AddItem(id, data)
    if not id or not data then 
        print("[DynamicTrading] Error: Invalid item data passed to AddItem")
        return 
    end
    -- Store data in the location your Economy.lua expects
    DynamicTrading.Config.MasterList[id] = data
end

-- 2. The Batch Loader 
function DynamicTrading.RegisterBatch(list)
    if not list then return end
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
    print("[DynamicTrading] Batch Loaded: " .. #list .. " items.")
end

function DynamicTrading.Config.GetRadioData(itemFullType)
    return DynamicTrading.Config.RadioTiers[itemFullType] or { power = 0.5, desc = "Unknown Device" }
end

-- =============================================================================
-- DIFFICULTY (Sandbox Driven)
-- =============================================================================
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

print("[DynamicTrading] Config & Registry Core Loaded.")

-- [SAFETY ALIAS]
-- Just in case any new scripts try to look for 'Items', we point it to MasterList too.
DynamicTrading.Items = DynamicTrading.Config.MasterList

-- [DEBUG HELPER]
-- This confirms your items are actually landing in the MasterList
local count = 0
for _ in pairs(DynamicTrading.Config.MasterList) do count = count + 1 end
print("[DynamicTrading] MASTERLIST CHECK: " .. count .. " items currently registered.")
