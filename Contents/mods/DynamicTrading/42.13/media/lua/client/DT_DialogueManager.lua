require "DynamicTrading_DialogueConfig"

DynamicTrading = DynamicTrading or {}
DynamicTrading.DialogueManager = {}

-- =============================================================================
-- 1. INTERNAL HELPERS
-- =============================================================================

-- Helper: Safely picks a random string from a table
local function PickRandom(pool)
    if not pool or #pool == 0 then return nil end
    return pool[ZombRand(#pool) + 1]
end

-- Helper: formats the string with dynamic variables
local function FormatMessage(text, args)
    if not text then return "..." end
    
    local player = getSpecificPlayer(0)
    local pName = player and player:getUsername() or "Survivor"
    
    -- Safe replacement to prevent crashes if args are nil
    local iName = args and args.itemName or "Item"
    local iPrice = args and args.price or 0
    
    text = string.gsub(text, "{player}", pName)
    text = string.gsub(text, "{item}", iName)
    text = string.gsub(text, "{price}", "$" .. iPrice)
    
    return text
end

-- Helper: safely retrieve the DB
local function GetDB()
    -- If missing, try to force load
    if not DynamicTrading.Dialogue then
        print("[DT-WARNING] Dialogue DB missing. Attempting re-require...")
        require "DynamicTrading_DialogueConfig"
    end
    return DynamicTrading.Dialogue
end

-- Helper: Finds the best pool of strings. 
-- Priority: Archetype Specific Subcategory -> General Subcategory -> General Default
local function GetDialoguePool(archetype, category, subContext)
    local db = GetDB()
    
    -- CRASH PREVENTION: If DB is still nil, return safe default
    if not db then 
        print("[DT-ERROR] DynamicTrading.Dialogue is nil! Check DynamicTrading_DialogueConfig.lua location.")
        return { "..." } 
    end

    -- 1. Try Archetype Specific
    -- Check if Archetypes table exists before indexing
    if db.Archetypes and db.Archetypes[archetype] then
        local archDB = db.Archetypes[archetype]
        if archDB[category] and archDB[category][subContext] then
            return archDB[category][subContext]
        end
    end

    -- 2. Try General Specific
    if db.General and db.General[category] and db.General[category][subContext] then
        return db.General[category][subContext]
    end

    -- 3. Fallback to General Default (Safety Net)
    if db.General and db.General[category] and db.General[category]["Default"] then
        return db.General[category]["Default"]
    end
    
    -- 4. Fallback to Generic (Buying/Selling often use 'Generic' instead of 'Default')
    if db.General and db.General[category] and db.General[category]["Generic"] then
        return db.General[category]["Generic"]
    end

    return { "..." }
end

-- =============================================================================
-- 2. GREETING GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateGreeting(trader)
    if not trader then return "..." end
    
    local cm = ClimateManager:getInstance()
    local gt = GameTime:getInstance()
    local hour = gt:getHour()
    
    local subContext = "Default"

    -- A. Check Weather (Priority)
    if cm:getRainIntensity() > 0.4 then
        subContext = "Raining"
    elseif cm:getFogIntensity() > 0.4 then
        subContext = "Fog"
    else
        -- B. Check Time
        if hour >= 5 and hour < 10 then
            subContext = "Morning"
        elseif hour >= 17 and hour < 21 then
            subContext = "Evening"
        elseif hour >= 21 or hour < 5 then
            subContext = "Night"
        end
    end

    local pool = GetDialoguePool(trader.archetype, "Greetings", subContext)
    local rawText = PickRandom(pool)
    
    return FormatMessage(rawText, {})
end

-- =============================================================================
-- 3. IDLE GENERATOR (NEW)
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
    if not trader then return "..." end
    
    -- Currently relies on 'Default', but logic allows expansion (e.g., if Raining)
    local subContext = "Default" 
    
    local pool = GetDialoguePool(trader.archetype, "Idle", subContext)
    local rawText = PickRandom(pool)
    
    return FormatMessage(rawText, {})
end

-- =============================================================================
-- 4. TRANSACTION GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, args)
    if not trader then return "..." end
    local safeArgs = args or {}
    
    local category = isBuy and "Buying" or "Selling"
    local subContext = "Generic"

    -- A. FAILURE SCENARIOS (Buying Only)
    if isBuy and not safeArgs.success then
        if safeArgs.failReason == "SoldOut" then
            subContext = "SoldOut"
        elseif safeArgs.failReason == "NoCash" then
            subContext = "NoCash"
        end
        local pool = GetDialoguePool(trader.archetype, category, subContext)
        return FormatMessage(PickRandom(pool), safeArgs)
    end

    -- B. SUCCESS SCENARIOS
    local price = safeArgs.price or 0
    local base = safeArgs.basePrice or price 
    if base <= 0 then base = 1 end
    
    if isBuy then
        -- BUYING LOGIC
        local ratio = price / base
        
        if price >= 200 then
            subContext = "HighValue"
        elseif ratio > 1.2 then
            subContext = "HighMarkup" -- Trader ripped you off
        elseif ratio < 0.9 then
            subContext = "LowMarkup" -- You got a deal
        else
            subContext = "Generic"
        end
    else
        -- SELLING LOGIC
        if price >= 200 then
            subContext = "HighValue"
        elseif price < 10 then
            subContext = "Trash"
        else
            subContext = "Generic"
        end
    end
    
    local pool = GetDialoguePool(trader.archetype, category, subContext)
    local rawText = PickRandom(pool)
    
    return FormatMessage(rawText, safeArgs)
end