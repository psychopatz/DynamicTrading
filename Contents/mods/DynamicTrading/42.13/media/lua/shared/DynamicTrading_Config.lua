DynamicTrading = DynamicTrading or {}
DynamicTrading.Config = {}
DynamicTrading.Config.MasterList = {} 
DynamicTrading.Config.Tags = {}
DynamicTrading.Archetypes = {}

-- =============================================================================
-- 1. DIFFICULTY REGISTRY
-- =============================================================================
-- These profiles determine the global economy state based on Sandbox Settings.
DynamicTrading.Config.DifficultyProfiles = {
    [1] = { -- Easy
        name = "Easy",
        buyMult = 0.7,    -- Items cost 30% less
        sellMult = 1.3,   -- Traders pay you 30% more
        stockMult = 1.5,  -- 50% more items in stock
        rarityBonus = 20  -- +20 flat weight to Rare items (Common)
    },
    [2] = { -- Normal
        name = "Normal",
        buyMult = 1.0,
        sellMult = 1.0,
        stockMult = 1.0,
        rarityBonus = 0
    },
    [3] = { -- Hard
        name = "Hard",
        buyMult = 1.5,    -- Items cost 50% more
        sellMult = 0.6,   -- Traders pay 40% less
        stockMult = 0.7,  -- Stock reduced by 30%
        rarityBonus = -5  -- Rare items are harder to find
    },
    [4] = { -- Super Hard
        name = "Insane",
        buyMult = 3.0,
        sellMult = 0.3,
        stockMult = 0.4,
        rarityBonus = -10 -- Rares are almost non-existent
    }
}

-- Helper to get current difficulty data safely
function DynamicTrading.Config.GetDifficultyData()
    local sandboxVal = SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.Difficulty or 2
    return DynamicTrading.Config.DifficultyProfiles[sandboxVal] or DynamicTrading.Config.DifficultyProfiles[2]
end

-- =============================================================================
-- 2. TAGS API (The "DNA" of items)
-- =============================================================================
-- priceMult: Permanent price modifier (1.1 = +10%)
-- weight:    Spawn probability in Wildcard slots (Higher = Common)
function DynamicTrading.RegisterTag(tag, data)
    if not tag or not data then return end
    
    -- Set defaults
    if not data.priceMult then data.priceMult = 1.0 end
    if not data.weight then data.weight = 50 end
    
    DynamicTrading.Config.Tags[tag] = data
end

-- =============================================================================
-- 3. ARCHETYPE API (The "Traders")
-- =============================================================================
function DynamicTrading.RegisterArchetype(id, data)
    if not id or not data then return end
    
    data.name = data.name or id
    
    -- allocations: Guaranteed stock { ["TagOrCategory"] = Count }
    data.allocations = data.allocations or {} 
    
    -- wants: Bonus price when buying FROM player { ["Tag"] = 1.25 }
    data.wants = data.wants or {} 
    
    -- forbid: Tags that will never generate in this shop { "Tag1", "Tag2" }
    data.forbid = data.forbid or {} 
    
    DynamicTrading.Archetypes[id] = data
    print("[DynamicTrading] Registered Archetype: " .. id)
end

-- =============================================================================
-- 4. ITEM API (The "Goods")
-- =============================================================================
function DynamicTrading.AddItem(uniqueID, data)
    if not uniqueID or not data then return end
    
    -- 1. Validate / Set Defaults
    if not data.basePrice then data.basePrice = 10 end
    
    -- 2. Handle Tags
    if not data.tags then data.tags = { "Misc" } end
    -- Ensure all items have at least one valid tag for the economy engine
    local hasValid = false
    for _, t in ipairs(data.tags) do if t then hasValid = true break end end
    if not hasValid then table.insert(data.tags, "Misc") end

    -- 3. Handle Stock Range
    if not data.stockRange then data.stockRange = {min=1, max=5} end
    
    -- 4. Handle Weight/Chance
    -- If 'chance' is nil, the engine will calculate it based on Tags later.
    -- If 'chance' is set, it overrides the Tag weights.
    
    DynamicTrading.Config.MasterList[uniqueID] = data
end

print("[DynamicTrading] Config Core Loaded.")