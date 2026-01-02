DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = {}
DynamicTrading.Config.MasterList = {} 
DynamicTrading.Config.Tags = {}
DynamicTrading.Archetypes = {}

-- [Keep RadioTiers table as is...]
DynamicTrading.Config.RadioTiers = {
    ["Base.WalkieTalkie1"]          = { power = 0.5, desc = "Weak Signal (Toy)" },
    ["Base.WalkieTalkieMakeShift"]  = { power = 0.6, desc = "Weak Signal (Makeshift)" },
    ["Base.WalkieTalkie2"]          = { power = 0.8, desc = "Average Signal" },
    ["Base.WalkieTalkie3"]          = { power = 1.0, desc = "Good Signal" },
    ["Base.WalkieTalkie4"]          = { power = 1.2, desc = "Strong Signal" },
    ["Base.WalkieTalkie5"]          = { power = 1.5, desc = "Military Grade" },
    ["Base.HamRadioMakeShift"]      = { power = 1.2, desc = "Stationary (Makeshift)" },
    ["Base.HamRadio1"]              = { power = 1.5, desc = "Stationary (Premium)" },
    ["Base.HamRadio2"]              = { power = 2.0, desc = "Stationary (Military)" },
    ["Base.ManPackRadio"]           = { power = 1.5, desc = "Military Manpack" }
}

function DynamicTrading.Config.GetRadioData(itemFullType)
    return DynamicTrading.Config.RadioTiers[itemFullType] or { power = 0.5, desc = "Unknown Device" }
end

-- =============================================================================
-- DIFFICULTY (Now purely Sandbox Driven)
-- =============================================================================
function DynamicTrading.Config.GetDifficultyData()
    -- Create the data object directly from Sandbox variables
    return {
        name        = "Custom Sandbox", -- Static name since we don't have presets anymore
        buyMult     = SandboxVars.DynamicTrading.PriceBuyMult or 1.0,
        sellMult    = SandboxVars.DynamicTrading.PriceSellMult or 0.5,
        stockMult   = SandboxVars.DynamicTrading.StockMult or 1.0,
        rarityBonus = SandboxVars.DynamicTrading.RarityBonus or 0
    }
end

function DynamicTrading.RegisterTag(tag, data)
    if not tag or not data then return end
    if not data.priceMult then data.priceMult = 1.0 end
    if not data.weight then data.weight = 50 end
    DynamicTrading.Config.Tags[tag] = data
end

function DynamicTrading.RegisterArchetype(id, data)
    if not id or not data then return end
    data.name = data.name or id
    data.allocations = data.allocations or {} 
    data.wants = data.wants or {} 
    data.forbid = data.forbid or {} 
    DynamicTrading.Archetypes[id] = data
end

function DynamicTrading.AddItem(uniqueID, data)
    if not uniqueID or not data then return end
    if not data.basePrice then data.basePrice = 10 end
    if not data.tags then data.tags = { "Misc" } end
    local hasValid = false
    for _, t in ipairs(data.tags) do if t then hasValid = true break end end
    if not hasValid then table.insert(data.tags, "Misc") end
    if not data.stockRange then data.stockRange = {min=1, max=5} end
    DynamicTrading.Config.MasterList[uniqueID] = data
end

print("[DynamicTrading] Config Loaded.")