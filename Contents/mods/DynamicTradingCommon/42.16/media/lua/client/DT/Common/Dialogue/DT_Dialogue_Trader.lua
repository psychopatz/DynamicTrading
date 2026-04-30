require "DT/Common/Dialogue/DT_Dialogue_Core"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Trader = {}

local Core = DynamicTrading.Dialogue.Core
local DEBUG_PREFIX = "[DT-Common-Dialogue]"

local function getRepAwareGreeting(trader)
    local rep = trader and trader.reputation or 0
    
    if rep >= 40 then
        return {
            "Good to hear from you again, {player.firstname}.",
            "You're one of the few I trust around here, {player}.",
            "Signal's clear. For you, I've got time."
        }
    elseif rep >= 10 then
        return {
            "You again, {player.firstname}? That's fine by me.",
            "I've dealt with worse than you. Go on.",
            "You're alright. Let's hear it."
        }
    elseif rep <= -40 then
        return {
            "Make this quick, {player}. I haven't forgotten.",
            "You have a lot of nerve calling me.",
            "Say what you need and be done with it."
        }
    elseif rep <= -10 then
        return {
            "What do you want this time?",
            "I'm listening, but don't test me.",
            "Keep it brief, {player.firstname}."
        }
    end
    
    return nil
end

local function getRepAwareIdle(trader)
    local rep = trader and trader.reputation or 0
    if rep >= 40 then
        return {
            "If it's you, I can spare a minute.",
            "Business is easier when I know who's calling."
        }
    elseif rep <= -40 then
        return {
            "Bad blood doesn't just vanish.",
            "Some debts aren't paid in cash."
        }
    end
    return nil
end

-- =============================================================================
-- 2. GREETING GENERATOR
-- =============================================================================
function DynamicTrading.Dialogue.Trader.GenerateGreeting(trader)
    if not trader then return "..." end
    
    local repPool = getRepAwareGreeting(trader)
    if repPool then
        return Core.FormatMessage(Core.PickRandom(repPool), { traderName = trader.name })
    end
    
    -- Check if trader has no budget - use NoBudget subcontext
    if trader.budget ~= nil and tonumber(trader.budget) <= 0 then
        local pool = Core.GetDialoguePool(trader.archetype, "Greetings", "NoBudget")
        if pool and #pool > 0 then
            return Core.FormatMessage(Core.PickRandom(pool), {})
        end
        -- Fallback to General archetype if archetype doesn't have NoBudget
        pool = Core.GetDialoguePool("General", "Greetings", "NoBudget")
        if pool and #pool > 0 then
            return Core.FormatMessage(Core.PickRandom(pool), {})
        end
    end
    
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
    
    local pool = Core.GetDialoguePool(trader.archetype, "Greetings", subContext)
    return Core.FormatMessage(Core.PickRandom(pool), {})
end

-- =============================================================================
-- 3. IDLE GENERATOR
-- =============================================================================
function DynamicTrading.Dialogue.Trader.GenerateIdleMessage(trader)
    if not trader then return "..." end
    local repPool = getRepAwareIdle(trader)
    if repPool then
        return Core.FormatMessage(Core.PickRandom(repPool), { traderName = trader.name })
    end
    local pool = Core.GetDialoguePool(trader.archetype, "Idle", "Default")
    return Core.FormatMessage(Core.PickRandom(pool), {})
end

-- =============================================================================
-- 4. AMBIENT GENERATOR
-- =============================================================================
function DynamicTrading.Dialogue.Trader.GenerateAmbientMessage(trader, eventType)
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
    
    local pool = Core.GetDialoguePool(trader.archetype, category, subContext)
    return Core.FormatMessage(Core.PickRandom(pool), {})
end

-- =============================================================================
-- 5. TRADER TRANSACTION GENERATOR
-- =============================================================================
function DynamicTrading.Dialogue.Trader.GenerateTransactionMessage(trader, isBuy, args)
    if not trader then return "..." end
    local safeArgs = args or {}
    
    if tostring(safeArgs.transactionKind or "") == "gift" then
        if not safeArgs.success then
            local failLines = {
                "Keep it. I don't want a cursed gift.",
                "Not now. Take it back.",
                "I said no. Keep your item.",
            }
            return Core.FormatMessage(failLines[ZombRand(#failLines) + 1], safeArgs)
        end
        
        local price = tonumber(safeArgs.price) or 0
        local giftLines = nil
        if price >= 200 then
            giftLines = {
                "That's generous. I won't forget it.",
                "A gift like that travels farther than words.",
                "You just bought a lot of goodwill without buying anything at all.",
            }
        elseif price < 10 then
            giftLines = {
                "A small gesture still counts.",
                "Not much, but I get the meaning.",
                "I've seen worse peace offerings.",
            }
        else
            giftLines = {
                "I'll take it. Appreciated.",
                "That's thoughtful. Thank you.",
                "A gift like that smooths things over.",
            }
        end
        
        return Core.FormatMessage(giftLines[ZombRand(#giftLines) + 1], safeArgs)
    end
    
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
        local pool = Core.GetDialoguePool(trader.archetype, category, subContext)
        return Core.FormatMessage(Core.PickRandom(pool), safeArgs)
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
    
    local pool = Core.GetDialoguePool(trader.archetype, category, subContext)
    return Core.FormatMessage(Core.PickRandom(pool), safeArgs)
end

-- =============================================================================
-- 7. SELL-ASK DIALOGUE GENERATOR (V2 Improved Logic)
-- =============================================================================

-- Helper: Formats a list of tags with "and" and random suffixes
local function FormatNaturalList(list)
    if not list or #list == 0 then return "nothing in particular" end
    
    local suffixes = {"", " things", " stuff", " items", " goods", " supplies"}
    local processed = {}
    for i, item in ipairs(list) do
        local suffix = suffixes[ZombRand(#suffixes) + 1]
        table.insert(processed, (item or "misc") .. suffix)
    end
    
    if #processed == 1 then return processed[1] end
    
    local last = table.remove(processed)
    return table.concat(processed, ", ") .. " and " .. last
end

function DynamicTrading.Dialogue.Trader.GenerateSellAskDialogue(trader)
    if not trader then return "..." end
    -- if DynamicTrading.Debug then print(DEBUG_PREFIX .. " GenerateSellAskDialogue for archetype: " .. tostring(trader.archetype)) end
    
    local db = Core.GetDB()
    local archetype = trader.archetype or "General"
    
    -- 1. Try to Load Archetype File Dynamically (Decoupling Support)
    if archetype ~= "General" then
        -- Check if table already has data, if not try to load
        if not db.Archetypes[archetype] or not db.Archetypes[archetype].SellAskResponse then
            if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Dialogue", "Trader", "Attempting to load archetype file: DT/Common/ArchetypeDefinitions/" .. archetype .. "/Dialogue/Sell_ask") end
            
            pcall(require, "DT/Common/ArchetypeDefinitions/" .. archetype .. "/Dialogue/Sell_ask")
        end
    end
    
    -- 2. Get Archetype Data (Tags for formatting)
    local archData = DynamicTrading.Archetypes[archetype] or DynamicTrading.Archetypes["General"]
    
    -- 3. Format Wants
    local wantsList = {}
    if archData and archData.wants then
        for tag, mult in pairs(archData.wants) do
            table.insert(wantsList, DynamicTrading.Utils.FormatTagDialogue(tag))
        end
    end
    local wantsStr = FormatNaturalList(wantsList)
    
    -- 4. Format Forbid
    local rawForbidList = archData and archData.forbid or {}
    local forbidList = {}
    for _, tag in ipairs(rawForbidList) do
        table.insert(forbidList, DynamicTrading.Utils.FormatTagDialogue(tag))
    end
    local forbidStr = FormatNaturalList(forbidList)
    
    -- 5. Determine Message Pool (Priority: Archetype > General)
    local pool = nil
    
    if db.Archetypes[archetype] and db.Archetypes[archetype].Sell_ask then
        pool = Core.GetDialoguePool(archetype, "Sell_ask", "Default")
    elseif db.General and db.General.Sell_ask then
        pool = Core.GetDialoguePool("General", "Sell_ask", "Default")
    else
        pool = { "I'm looking for {wants}. No {forbid}." }
    end
    
    local rawText = Core.PickRandom(pool)
    
    -- 6. Format Variables
    local text = string.gsub(rawText, "{wants}", wantsStr)
    text = string.gsub(text, "{forbid}", forbidStr)
    
    return Core.FormatMessage(text, {})
end
