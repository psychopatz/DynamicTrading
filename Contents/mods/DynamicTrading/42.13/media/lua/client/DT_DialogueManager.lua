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
    if not DynamicTrading.Dialogue then
        -- Attempt to reload if missing (Safety Net)
        require "DynamicTrading_DialogueConfig"
    end
    return DynamicTrading.Dialogue
end

-- Helper: Finds the best pool of strings based on Trader Archetype
-- Priority: Archetype Specific -> General Specific -> General Default -> Generic
local function GetDialoguePool(archetype, category, subContext)
    local db = GetDB()
    if not db then return { "..." } end

    -- 1. Try Archetype Specific (e.g., Sheriff -> Greetings -> Morning)
    if db.Archetypes and db.Archetypes[archetype] then
        local archDB = db.Archetypes[archetype]
        if archDB[category] and archDB[category][subContext] then
            return archDB[category][subContext]
        end
    end

    -- 2. Try General Specific (e.g., General -> Greetings -> Morning)
    if db.General and db.General[category] and db.General[category][subContext] then
        return db.General[category][subContext]
    end

    -- 3. Fallback to General Default
    if db.General and db.General[category] and db.General[category]["Default"] then
        return db.General[category]["Default"]
    end
    
    -- 4. Final Fallback (Generic)
    if db.General and db.General[category] and db.General[category]["Generic"] then
        return db.General[category]["Generic"]
    end

    return { "..." }
end

-- =============================================================================
-- 2. GREETING GENERATOR (On Window Open)
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateGreeting(trader)
    if not trader then return "..." end
    
    local cm = ClimateManager:getInstance()
    local gt = GameTime:getInstance()
    local hour = gt:getHour()
    
    local subContext = "Default"

    -- Priority Logic: Weather > Time
    if cm:getRainIntensity() > 0.4 then
        subContext = "Raining"
    elseif cm:getFogIntensity() > 0.4 then
        subContext = "Fog"
    else
        -- Time Contexts
        if hour >= 5 and hour < 10 then subContext = "Morning"
        elseif hour >= 17 and hour < 21 then subContext = "Evening"
        elseif hour >= 21 or hour < 5 then subContext = "Night"
        end
    end

    local pool = GetDialoguePool(trader.archetype, "Greetings", subContext)
    return FormatMessage(PickRandom(pool), {})
end

-- =============================================================================
-- 3. IDLE GENERATOR (Triggered by Timer)
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
    if not trader then return "..." end
    
    -- We use "Idle" category. 
    -- Currently only "Default" exists, but logic supports "Raining" etc if you add it later.
    local subContext = "Default" 
    
    local pool = GetDialoguePool(trader.archetype, "Idle", subContext)
    return FormatMessage(PickRandom(pool), {})
end

-- =============================================================================
-- 4. AMBIENT GENERATOR (NEW - Triggered by Environment Changes)
-- =============================================================================
-- This function maps specific events (Time/Weather) to existing dialogue categories.
-- This allows the NPC to comment on changes without needing a massive new config.
function DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, eventType)
    if not trader or not eventType then return nil end
    
    -- Map the "Event" to a "Dialogue Category"
    -- We reuse "Greetings" categories because they usually contain observations like 
    -- "Sun is coming up" or "It's raining".
    local category = "Greetings" 
    local subContext = "Default"

    if eventType == "Morning" then subContext = "Morning"
    elseif eventType == "Evening" then subContext = "Evening"
    elseif eventType == "Night" then subContext = "Night"
    elseif eventType == "RainStart" then subContext = "Raining"
    elseif eventType == "FogStart" then subContext = "Fog"
    elseif eventType == "RainStop" then 
        -- If you don't have a "ClearSky" category, fall back to Default
        subContext = "Default" 
    end

    -- Fetch the pool
    local pool = GetDialoguePool(trader.archetype, category, subContext)
    
    -- [Logic Tweak]
    -- Since we are reusing Greeting lines, some might sound weird mid-conversation 
    -- (e.g. "Hello!"). In a polished mod, you would create a separate "Ambient" category
    -- in your Config file. For now, this reusing method works for 90% of lines.
    
    return FormatMessage(PickRandom(pool), {})
end

-- =============================================================================
-- 5. TRANSACTION GENERATOR (Buying/Selling)
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, args)
    if not trader then return "..." end
    local safeArgs = args or {}
    
    local category = isBuy and "Buying" or "Selling"
    local subContext = "Generic"

    -- A. FAILURE SCENARIOS
    if isBuy and not safeArgs.success then
        if safeArgs.failReason == "SoldOut" then subContext = "SoldOut"
        elseif safeArgs.failReason == "NoCash" then subContext = "NoCash"
        end
        local pool = GetDialoguePool(trader.archetype, category, subContext)
        return FormatMessage(PickRandom(pool), safeArgs)
    end

    -- B. SUCCESS SCENARIOS
    local price = safeArgs.price or 0
    local base = safeArgs.basePrice or price 
    if base <= 0 then base = 1 end
    
    if isBuy then
        local ratio = price / base
        if price >= 200 then subContext = "HighValue"
        elseif ratio > 1.2 then subContext = "HighMarkup"
        elseif ratio < 0.9 then subContext = "LowMarkup"
        else subContext = "Generic" end
    else
        if price >= 200 then subContext = "HighValue"
        elseif price < 10 then subContext = "Trash"
        else subContext = "Generic" end
    end
    
    local pool = GetDialoguePool(trader.archetype, category, subContext)
    return FormatMessage(PickRandom(pool), safeArgs)
end