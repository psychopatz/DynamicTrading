require "DT/Common/Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Core = {}

-- =============================================================================
-- 1. INTERNAL HELPERS
-- =============================================================================

-- Helper: Safely picks a random string from a table
function DynamicTrading.Dialogue.Core.PickRandom(pool)
    if not pool or #pool == 0 then return nil end
    return pool[ZombRand(#pool) + 1]
end

-- Helper: formats the string with dynamic variables
function DynamicTrading.Dialogue.Core.FormatMessage(text, args)
    if not text then return "..." end
    
    local player = getSpecificPlayer(0)
    
    -- Name Resolution Logic
    local pFirst = "Survivor"
    local pLast = ""
    local pFull = "Survivor"

    if player then
        local desc = player:getDescriptor()
        if desc then
            pFirst = desc:getForename() or "Survivor"
            pLast = desc:getSurname() or ""
        else
            -- Fallback if descriptor is missing
            pFirst = player:getUsername() or "Survivor"
        end
        
        -- Build Full Name with Space
        if pLast ~= "" then
            pFull = pFirst .. " " .. pLast
        else
            pFull = pFirst
        end
    end
    
    -- Safe replacement for items/price
    local iName = args and args.itemName or "Item"
    local iPrice = args and args.price or 0
    
    -- Substitution Logic
    -- 1. Specific Name Parts
    text = string.gsub(text, "{player%.firstname}", pFirst)
    text = string.gsub(text, "{player%.surname}", pLast)
    
    -- 2. Full Name
    text = string.gsub(text, "{player}", pFull)

    -- 2b. NPC Name (if available)
    local nName = args and args.traderName or "Trader"
    text = string.gsub(text, "{npc}", nName)
    text = string.gsub(text, "{npc%.name}", nName)
    
    -- 3. Item & Price
    text = string.gsub(text, "{item}", iName)
    text = string.gsub(text, "{price}", "$" .. iPrice)
    
    return text
end

-- Helper: safely retrieve the DB
function DynamicTrading.Dialogue.Core.GetDB()
    if not DynamicTrading.Dialogue.Archetypes then
        -- Trigger a reload/check if needed, but usually Config loads it
        -- require "DT/Common/Config" 
    end
    return DynamicTrading.Dialogue
end

-- Helper: Finds the best pool of strings based on Trader Archetype and Language
function DynamicTrading.Dialogue.Core.GetDialoguePool(archetype, category, subContext)
    local db = DynamicTrading.Dialogue.Core.GetDB()
    if not db then return { "..." } end

    local lang = DynamicTrading.GetLanguage()

    -- Helper to check a specific table for language-aware dialogues
    local function GetFromTarget(target)
        if not target or not target[category] then return nil end
        
        local categoryTable = target[category]
        
        -- 1. If it's a direct array (old format), just return it
        if categoryTable[1] then return categoryTable end
        
        -- 2. Structure 1: Lang -> Context -> Lines (Preferred, e.g. Angler)
        if categoryTable[lang] then
            local lTable = categoryTable[lang]
            local pool = lTable[subContext] or lTable["Default"] or lTable["Generic"] or (lTable[1] and lTable)
            if pool then return pool end
        end
        if categoryTable["EN"] then
            local lTable = categoryTable["EN"]
            local pool = lTable[subContext] or lTable["Default"] or lTable["Generic"] or (lTable[1] and lTable)
            if pool then return pool end
        end

        -- 3. Structure 2: Context -> Lang -> Lines (Fallback/Mixed Style)
        local subTable = categoryTable[subContext] or categoryTable["Default"] or categoryTable["Generic"]
        if subTable then
            return subTable[lang] or subTable["EN"] or subTable -- Fallback to direct array if not keyed
        end

        return nil
    end

    -- 1. Try Archetype Specific
    if db.Archetypes and db.Archetypes[archetype] then
        local pool = GetFromTarget(db.Archetypes[archetype])
        if pool then return pool end
    end

    -- 2. Try General Specific (Fallback for all traders)
    if db.Archetypes and db.Archetypes["General"] then
        local pool = GetFromTarget(db.Archetypes["General"])
        if pool then return pool end
    end

    -- 3. Try Player Specific (Last resort fallback)
    if db.Archetypes and db.Archetypes["Player"] then
        local pool = GetFromTarget(db.Archetypes["Player"])
        if pool then return pool end
    end

    return { "..." }
end
