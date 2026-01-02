DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = {}
DynamicTrading.Config.MasterList = {} 
DynamicTrading.Config.Tags = {}
DynamicTrading.Archetypes = {}

-- =============================================================================
-- RADIO TIERS (Based on Transmit Range)
-- =============================================================================
-- The key MUST match the Item ID exactly.
DynamicTrading.Config.RadioTiers = {
    -- LOW TIER (Toys / Makeshift)
    ["Base.WalkieTalkie1"]          = { power = 0.5, desc = "Weak Signal (Toy)" },       -- Toy (750m)
    ["Base.WalkieTalkieMakeShift"]  = { power = 0.6, desc = "Weak Signal (Makeshift)" }, -- Makeshift (1000m)
    
    -- MID TIER (Civilian)
    ["Base.WalkieTalkie2"]          = { power = 0.8, desc = "Average Signal" },          -- ValuTech (2000m)
    ["Base.WalkieTalkie3"]          = { power = 1.0, desc = "Good Signal" },             -- Premium (4000m)
    
    -- HIGH TIER (Tactical / Military)
    ["Base.WalkieTalkie4"]          = { power = 1.2, desc = "Strong Signal" },           -- Tactical (8000m)
    ["Base.WalkieTalkie5"]          = { power = 1.5, desc = "Military Grade" },          -- US Army (16000m)
    
    -- HAM RADIOS (Stationary)
    ["Base.HamRadioMakeShift"]      = { power = 1.2, desc = "Stationary (Makeshift)" },
    ["Base.HamRadio1"]              = { power = 1.5, desc = "Stationary (Premium)" },
    ["Base.HamRadio2"]              = { power = 2.0, desc = "Stationary (Military)" },
    ["Base.ManPackRadio"]           = { power = 1.5, desc = "Military Manpack" }         -- Treated as Ham/High Tier
}

function DynamicTrading.Config.GetRadioData(itemFullType)
    return DynamicTrading.Config.RadioTiers[itemFullType] or { power = 0.5, desc = "Unknown Device" }
end

-- ... (Keep the rest of your DifficultyProfiles and Register functions below) ...
-- =============================================================================
-- DIFFICULTY REGISTRY
-- =============================================================================
DynamicTrading.Config.DifficultyProfiles = {
    [1] = { name="Easy",   buyMult=0.7, sellMult=1.3, stockMult=1.5, rarityBonus=20 },
    [2] = { name="Normal", buyMult=1.0, sellMult=1.0, stockMult=1.0, rarityBonus=0 },
    [3] = { name="Hard",   buyMult=1.5, sellMult=0.6, stockMult=0.7, rarityBonus=-5 },
    [4] = { name="Insane", buyMult=3.0, sellMult=0.3, stockMult=0.4, rarityBonus=-10 }
}

function DynamicTrading.Config.GetDifficultyData()
    local sandboxVal = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.Difficulty or 2
    return DynamicTrading.Config.DifficultyProfiles[sandboxVal] or DynamicTrading.Config.DifficultyProfiles[2]
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

print("[DynamicTrading] Config & Radio Tiers Loaded.")