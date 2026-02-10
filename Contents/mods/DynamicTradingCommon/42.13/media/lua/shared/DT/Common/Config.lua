DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = DynamicTrading.Config or {}

-- =============================================================================
-- 1. ITEM REGISTRY
-- =============================================================================
DynamicTrading.Config.MasterList = DynamicTrading.Config.MasterList or {}

-- Single Item Adder
function DynamicTrading.AddItem(id, data)
    if not id or not data then 
        print("[DynamicTrading] Error: Invalid item data passed to AddItem")
        return 
    end
    DynamicTrading.Config.MasterList[id] = data
end

-- Batch Item Loader 
function DynamicTrading.RegisterBatch(list)
    if not list then return end
    for _, data in ipairs(list) do
        DynamicTrading.AddItem(data.item, data)
    end
    -- Reduced spam: only print batch totals
    print("[DynamicTrading] Item Batch Loaded: " .. #list .. " entries.")
end

-- =============================================================================
-- 2. ARCHETYPE REGISTRY
-- =============================================================================
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

-- The Core Function: Preserves your ID schema
function DynamicTrading.RegisterArchetype(id, data)
    if not id then 
        print("[DynamicTrading] Error: Archetype registered without ID.")
        return 
    end
    if not data then return end
    
    -- Ensure the ID is inside the data table too, just in case, 
    -- but primarily use it as the Table Key for lookups.
    data.id = id 
    
    DynamicTrading.Archetypes[id] = data
    
    -- Debug Print (Requested)
    print("[DynamicTrading] Registered Archetype: " .. id)
end

-- =============================================================================
-- 3. GAMEPLAY HELPERS
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

print("[DynamicTrading] Config & Registry Core Loaded.")


