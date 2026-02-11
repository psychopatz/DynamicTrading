require "DT/Common/Config"

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
local function GetDB()
    if not DynamicTrading.Dialogue then
        require "DT/Common/Config"
    end
    return DynamicTrading.Dialogue
end

-- Helper: Finds the best pool of strings based on Trader Archetype and Language
local function GetDialoguePool(archetype, category, subContext)
    local db = GetDB()
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

    -- 2. Try General Specific
    if db.General then
        local pool = GetFromTarget(db.General)
        if pool then return pool end
    end

    return { "..." }
end

-- =============================================================================
-- 2. GREETING GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GetDialogue(trader, category, subContext, args)
    if not trader or not category or not subContext then return "..." end
    
    local safeArgs = args or {}
    if trader.name and not safeArgs.traderName then
        safeArgs.traderName = trader.name
    end
    
    local pool = GetDialoguePool(trader.archetype, category, subContext)
    local rawText = PickRandom(pool)
    return FormatMessage(rawText, safeArgs)
end

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
    if not safeArgs.success then
        if isBuy then
            if safeArgs.failReason == "SoldOut" then subContext = "SoldOut"
            elseif safeArgs.failReason == "NoCash" then subContext = "NoCash"
            end
        else
            if safeArgs.failReason == "NoCash" then subContext = "NoCash" end
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

-- =============================================================================
-- 7. [NEW] SELL-ASK DIALOGUE GENERATOR
-- =============================================================================
function DynamicTrading.DialogueManager.GeneratePlayerSellAskMessage()
    local db = GetDB()
    local pool = (db.Player and db.Player.SellAsk) and db.Player.SellAsk or { "What are you buying?" }
    local rawText = PickRandom(pool)
    return FormatMessage(rawText, {})
end

-- Helper: Formats a list of tags with "and" and random suffixes
local function FormatNaturalList(list)
    if not list or #list == 0 then return "nothing in particular" end
    
    local suffixes = {"", " things", " stuffs", " items", " goods", " supplies"}
    local processed = {}
    for i, item in ipairs(list) do
        local suffix = suffixes[ZombRand(#suffixes) + 1]
        table.insert(processed, (item or "misc") .. suffix)
    end
    
    if #processed == 1 then return processed[1] end
    
    local last = table.remove(processed)
    return table.concat(processed, ", ") .. " and " .. last
end

function DynamicTrading.DialogueManager.GenerateSellAskDialogue(trader)
    if not trader then return "..." end
    
    local db = GetDB()
    local archetype = trader.archetype or "General"

    -- 1. Try to Load Archetype File Dynamically (Decoupling Support)
    if archetype ~= "General" then
        -- Check if table already has data, if not try to load
        if not db.Archetypes[archetype] or not db.Archetypes[archetype].SellAskResponse then
            print("[DynamicTrading] Dialogue: Attempting to load archetype file: DT/Common/ArchetypeDefinitions/" .. archetype .. "/Dialogue/Sell_ask")
            
            -- PZ Lua handles 'require' paths relative to media/lua/shared or client
            -- pcall(require) in PZ might return true even if it logs a warning but if the file is truly 
            -- missing, the table won't be populated.
            pcall(require, "DT/Common/ArchetypeDefinitions/" .. archetype .. "/Dialogue/Sell_ask")
            
            -- Validate if it actually worked
            if db.Archetypes[archetype] and db.Archetypes[archetype].SellAskResponse then
                print("[DynamicTrading] Dialogue: Successfully loaded " .. archetype)
            else
                -- print("[DynamicTrading] Dialogue: Info - No unique file found for " .. archetype)
            end
        end
    end

    -- 2. Get Archetype Data (Tags for formatting)
    local archData = DynamicTrading.Archetypes[archetype] or DynamicTrading.Archetypes["General"]

    -- 3. Format Wants
    local wantsList = {}
    if archData and archData.wants then
        for tag, mult in pairs(archData.wants) do
            table.insert(wantsList, tag)
        end
    end
    local wantsStr = FormatNaturalList(wantsList)

    -- 4. Format Forbid
    local forbidList = archData and archData.forbid or {}
    local forbidStr = FormatNaturalList(forbidList)

    -- 5. Determine Message Pool (Priority: Archetype > General)
    local pool = nil
    
    if db.Archetypes[archetype] and db.Archetypes[archetype].Sell_ask then
        pool = GetDialoguePool(archetype, "Sell_ask", "Default")
    elseif db.General and db.General.Sell_ask then
        pool = GetDialoguePool("General", "Sell_ask", "Default")
    else
        pool = { "I'm looking for {wants}. No {forbid}." }
    end

    print("[DynamicTrading] Dialogue: Pool Selected -> " .. poolSource)

    local rawText = PickRandom(pool)

    -- 6. Format Variables
    local text = string.gsub(rawText, "{wants}", wantsStr)
    text = string.gsub(text, "{forbid}", forbidStr)
    
    return FormatMessage(text, {})
end
