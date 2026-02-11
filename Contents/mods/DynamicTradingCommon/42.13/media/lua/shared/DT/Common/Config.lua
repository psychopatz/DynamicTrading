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
    
    print("[DynamicTrading] Registered Archetype: " .. id)
end

-- =============================================================================
-- 3. DIALOGUE REGISTRY
-- =============================================================================
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Archetypes = DynamicTrading.Dialogue.Archetypes or {}

-- New RegisterDialogue for In-Code Translations
function DynamicTrading.RegisterDialogue(archetypeID, dialogueType, data)
    if not archetypeID or not dialogueType or not data then return end
    
    DynamicTrading.Dialogue.Archetypes[archetypeID] = DynamicTrading.Dialogue.Archetypes[archetypeID] or {}
    local archTable = DynamicTrading.Dialogue.Archetypes[archetypeID]
    
    archTable[dialogueType] = archTable[dialogueType] or {}
    
    -- Merge translations (supports overrides and cross-file loading)
    for lang, lines in pairs(data) do
        archTable[dialogueType][lang] = lines
    end

    -- [NEW] Backward Compatibility for Meta Archetypes (Player, General)
    if archetypeID == "Player" or archetypeID == "General" then
        DynamicTrading.Dialogue[archetypeID] = DynamicTrading.Dialogue[archetypeID] or {}
        local metaTable = DynamicTrading.Dialogue[archetypeID]
        
        -- Map "Buy" or "Buying" to "Buy" context etc.
        local targetKey = dialogueType
        if archetypeID == "Player" then
            if dialogueType == "Buying" then targetKey = "Buy"
            elseif dialogueType == "Selling" then targetKey = "Sell"
            elseif dialogueType == "Greetings" then targetKey = "Intro"
            end
        end

        for lang, lines in pairs(data) do
            if lang == "EN" then
                -- For player dialogues, they are often just the lines or context aware
                if lines.Generic or lines.Default then
                    local base = lines.Generic or lines.Default
                    metaTable[targetKey] = base
                    -- Explode context for player
                    if lines.LastStock then metaTable["BuyLast"] = lines.LastStock end
                    if lines.NoCash then metaTable["NoCash"] = lines.NoCash end
                else
                    metaTable[targetKey] = lines
                end
            end
        end
    end
end

-- Detection Helper: Returns the current game language code (e.g., "EN", "PH", "RU")
function DynamicTrading.GetLanguage()
    if Translator and Translator.getLanguage() then
        return Translator.getLanguage():toString()
    end
    return "EN" -- Default fallback
end

-- =============================================================================
-- 4. DYNAMIC LOADER
-- =============================================================================
DynamicTrading.Config.ArchetypeList = {
    "Angler", "Athlete", "Bartender", "Blacksmith", "Brewer", "Burglar", "Butcher",
    "Carpenter", "Chef", "Demo", "Designer", "Doctor", "Electrician", "Farmer", "Foreman",
    "Geek", "Gunrunner", "Herbalist", "Hiker", "Hunter", "Janitor", "Librarian", "Mechanic",
    "Musician", "Office", "Painter", "Pawnbroker", "Pharmacist", "Pyro",
    "Quartermaster", "RoadWarrior", "Scavenger", "Sheriff", "Smuggler",
    "Survivalist", "Tailor", "Teacher", "Tribal", "Welder",
    "General", "Player" -- Meta archetypes
}

local languages = { 
    "AR", "CA", "CH", "CN", "CS", "DA", "DE", "EN", "ES", "FI", 
    "FR", "HU", "ID", "IT", "JP", "KO", "NL", "NO", "PH", "PL", 
    "PT", "PTBR", "RO", "RU", "TH", "TR", "UA" 
}
local dialogueTypes = { "Greetings", "Buying", "Selling", "Sell_ask", "Idle", "Request" }

-- Debug Flag
DynamicTrading.Debug = true

function DynamicTrading.LoadArchetypes()
    print("[DynamicTrading] Starting Dynamic Archetype Loading...")
    local totalLoaded = 0
    local errors = 0
    
    for _, id in ipairs(DynamicTrading.Config.ArchetypeList) do
        if DynamicTrading.Debug then print("[DynamicTrading] Processing Archetype: " .. id) end

        -- 1. Load Archetype Definition (Item Data)
        local itemPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Items/DT_" .. id
        local itemOk, err = pcall(require, itemPath)
        if not itemOk then
             print("[DynamicTrading] [ERROR] Failed to load Item Definition for " .. id .. ": " .. tostring(err))
             errors = errors + 1
        end
        
        -- 2. Load Dialogues and Translations
        for _, dType in ipairs(dialogueTypes) do
            local baseDialoguePath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Dialogue/DT_" .. id .. "_" .. dType
            -- Attempt base require (English/Default)
            local success, dErr = pcall(require, baseDialoguePath)
            if success then
                if DynamicTrading.Debug then print("[DynamicTrading]   >> Loaded " .. dType .. " (Base)") end
                totalLoaded = totalLoaded + 1
            else
                -- Silent fail for missing dialogue files is expected behavior for some types
            end
            
            -- Attempt Translation loading
            for _, lang in ipairs(languages) do
                local transPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Dialogue/Translations/" .. lang .. "/DT_" .. id .. "_" .. dType .. "_" .. lang
                local tSuccess, _ = pcall(require, transPath)
                if tSuccess then
                    if DynamicTrading.Debug then print("[DynamicTrading]   >> Loaded " .. dType .. " (" .. lang .. ")") end
                end
            end
        end
    end
    
    print("[DynamicTrading] Dynamic Loading Complete. Total Modules: " .. totalLoaded .. " | Errors: " .. errors)
end

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

print("[DynamicTrading] Config & Registry Core Loaded.")

-- Trigger the loading process
DynamicTrading.LoadArchetypes()
