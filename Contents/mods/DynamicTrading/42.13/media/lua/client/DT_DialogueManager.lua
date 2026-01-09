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
    
    -- 3. Item & Price
    text = string.gsub(text, "{item}", iName)
    text = string.gsub(text, "{price}", "$" .. iPrice)
    
    return text
end

-- Helper: safely retrieve the DB
local function GetDB()
    if not DynamicTrading.Dialogue then
        require "DynamicTrading_DialogueConfig"
    end
    return DynamicTrading.Dialogue
end

-- Helper: Finds the best pool of strings based on Trader Archetype
local function GetDialoguePool(archetype, category, subContext)
    local db = GetDB()
    if not db then return { "..." } end

    -- 1. Try Archetype Specific
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
-- 2. GREETING GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateGreeting(trader)
    if not trader then return "..." end
    
    local cm = ClimateManager:getInstance()
    local gt = GameTime:getInstance()
    local hour = gt:getHour()
    
    local subContext = "Default"

    if cm:getRainIntensity() > 0.4 then
        subContext = "Raining"
    elseif cm:getFogIntensity() > 0.4 then
        subContext = "Fog"
    else
        if hour >= 5 and hour < 10 then subContext = "Morning"
        elseif hour >= 17 and hour < 21 then subContext = "Evening"
        elseif hour >= 21 or hour < 5 then subContext = "Night"
        end
    end

    local pool = GetDialoguePool(trader.archetype, "Greetings", subContext)
    return FormatMessage(PickRandom(pool), {})
end

-- =============================================================================
-- 3. IDLE GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
    if not trader then return "..." end
    local pool = GetDialoguePool(trader.archetype, "Idle", "Default")
    return FormatMessage(PickRandom(pool), {})
end

-- =============================================================================
-- 4. AMBIENT GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, eventType)
    if not trader or not eventType then return nil end
    
    local category = "Greetings" 
    local subContext = "Default"

    if eventType == "Morning" then subContext = "Morning"
    elseif eventType == "Evening" then subContext = "Evening"
    elseif eventType == "Night" then subContext = "Night"
    elseif eventType == "RainStart" then subContext = "Raining"
    elseif eventType == "FogStart" then subContext = "Fog"
    elseif eventType == "RainStop" then subContext = "Default" 
    end

    local pool = GetDialoguePool(trader.archetype, category, subContext)
    return FormatMessage(PickRandom(pool), {})
end

-- =============================================================================
-- 5. TRADER TRANSACTION GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, args)
    if not trader then return "..." end
    local safeArgs = args or {}
    
    local category = isBuy and "Buying" or "Selling"
    local subContext = "Generic"

    -- Failure Check
    if isBuy and not safeArgs.success then
        if safeArgs.failReason == "SoldOut" then subContext = "SoldOut"
        elseif safeArgs.failReason == "NoCash" then subContext = "NoCash"
        end
        local pool = GetDialoguePool(trader.archetype, category, subContext)
        return FormatMessage(PickRandom(pool), safeArgs)
    end

    -- Success Checks
    local price = safeArgs.price or 0
    local base = safeArgs.basePrice or price 
    if base <= 0 then base = 1 end
    
    if isBuy then
        if safeArgs.wasLastOne then
            subContext = "LastStock"
        else
            local ratio = price / base
            if price >= 200 then subContext = "HighValue"
            elseif ratio > 1.2 then subContext = "HighMarkup"
            elseif ratio < 0.9 then subContext = "LowMarkup"
            else subContext = "Generic" end
        end
    else
        if price >= 200 then subContext = "HighValue"
        elseif price < 10 then subContext = "Trash"
        else subContext = "Generic" end
    end
    
    local pool = GetDialoguePool(trader.archetype, category, subContext)
    return FormatMessage(PickRandom(pool), safeArgs)
end

-- =============================================================================
-- 6. PLAYER TRANSACTION GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GeneratePlayerMessage(action, args)
    if not action then action = "Buy" end
    
    -- LOGIC: Check failure reasons FIRST to override success logic
    if action == "Buy" and args then
        if args.failReason == "NoCash" then
            action = "NoCash" -- Switch to Haggling lines
        elseif args.wasLastOne then
            action = "BuyLast" -- Switch to Last Stock lines
        end
    end
    
    local db = GetDB()
    local pool = nil
    
    -- Try Config first
    if db and db.Player and db.Player[action] then
        pool = db.Player[action]
    else
        -- Fallback to local
        pool = PlayerDialogue[action]
    end
    
    local rawText = PickRandom(pool) or "..."
    return FormatMessage(rawText, args)
end