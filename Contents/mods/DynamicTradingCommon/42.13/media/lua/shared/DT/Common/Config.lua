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

    if archetypeID == "Player" and DynamicTrading.Debug then
         print("[DynamicTrading] Debug: Registered Player Dialogue: " .. dialogueType)
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

-- Helper to check file existence to avoid console spam
local function FileExists(path)
    local fullPath = "media/lua/shared/" .. path .. ".lua"
    local exists = false
    local checked = false
    
    if getZomboidFileSystem then
        local fs = getZomboidFileSystem()
        if fs then
            local file = fs:getFile(fullPath)
            if file and file:exists() then exists = true end
            checked = true
        end
    elseif ZomboidFileSystem and ZomboidFileSystem.instance then
            local file = ZomboidFileSystem.instance:getFile(fullPath)
            if file and file:exists() then exists = true end
            checked = true
    elseif fileExists then
            -- Some environments have this global
            if fileExists(fullPath) then exists = true end
            checked = true
    end
    
    -- Fallback: If we couldn't check (API missing), try to load anyway to be safe
    if not checked then 
        exists = true 
    end
    
    return exists
end

function DynamicTrading.LoadArchetypes()
    print("[DynamicTrading] Starting Dynamic Archetype Loading...")
    local totalLoaded = 0
    local errors = 0
    
    for _, id in ipairs(DynamicTrading.Config.ArchetypeList) do
        if DynamicTrading.Debug then print("[DynamicTrading] Processing Archetype: " .. id) end

        -- 1. Load Archetype Definition (Item Data)
        local itemPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Items/DT_" .. id
        -- Items are mandatory, so we still want to know if they fail, but checking existence first is cleaner
        if FileExists(itemPath) then
             local itemOk, err = pcall(require, itemPath)
             if not itemOk then
                  print("[DynamicTrading] [ERROR] Failed to load Item Definition for " .. id .. ": " .. tostring(err))
                  errors = errors + 1
             end
        else
             -- Warn if definition is missing entirely, as this might be critical
             if DynamicTrading.Debug then print("[DynamicTrading] [WARN] Missing Item Definition for: " .. id) end
        end
        
        -- 2. Load Dialogues and Translations
        for _, dType in ipairs(dialogueTypes) do
            local baseDialoguePath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Dialogue/DT_" .. id .. "_" .. dType
            
            -- Attempt base require (English/Default)
            if FileExists(baseDialoguePath) then
                local success, dErr = pcall(require, baseDialoguePath)
                if success then
                    if DynamicTrading.Debug then print("[DynamicTrading]   >> Loaded " .. dType .. " (Base)") end
                    totalLoaded = totalLoaded + 1
                end
            end
            
            -- Attempt Translation loading
            for _, lang in ipairs(languages) do
                local transPath = "DT/Common/ArchetypeDefinitions/" .. id .. "/Dialogue/Translations/" .. lang .. "/DT_" .. id .. "_" .. dType .. "_" .. lang
                
                if FileExists(transPath) then
                    local tSuccess, _ = pcall(require, transPath)
                    if tSuccess then
                        if DynamicTrading.Debug then print("[DynamicTrading]   >> Loaded " .. dType .. " (" .. lang .. ")") end
                    end
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

-- =============================================================================
-- 6. EVENT SYSTEM
-- =============================================================================
require "DT/Common/Events/DT_EventManager"

print("[DynamicTrading] Config & Registry Core Loaded.")
 
-- Trigger the loading process LATER to avoid recursive require loops
Events.OnGameBoot.Add(DynamicTrading.LoadArchetypes)
