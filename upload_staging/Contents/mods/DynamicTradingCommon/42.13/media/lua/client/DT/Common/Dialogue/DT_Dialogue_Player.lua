require "DT/Common/Dialogue/DT_Dialogue_Core"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Player = DynamicTrading.Dialogue.Player or {}

local Core = DynamicTrading.Dialogue.Core

-- =============================================================================
-- 6. PLAYER TRANSACTION GENERATOR
-- =============================================================================
function DynamicTrading.Dialogue.Player.GeneratePlayerMessage(action, args)
    if not action then action = "Buy" end
    
    if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Dialogue", "Player", "GeneratePlayerMessage called for: " .. tostring(action)) end
    -- LOGIC: Check failure reasons FIRST to override success logic
    if (action == "Buy" or action == "Sell") and args then
        if args.failReason == "NoCash" then
            action = "NoCash" -- Switch to Haggling lines
        elseif action == "Buy" and args.wasLastOne then
            action = "BuyLast" -- Switch to Last Stock lines
        end
    end
    
    -- 1. Ensure Player Data is Loaded (Boot-load fallback)
    -- If things are missing, it's likely a load order issue or missing file
    if not Core.GetDialoguePool("Player", "Greetings", "Default")[1] or Core.GetDialoguePool("Player", "Greetings", "Default")[1] == "..." then
        if DynamicTrading.Debug then DynamicTrading.Log("DTCommons", "Dialogue", "Player", "Dialogue: Player Greeting pool missing. Attempting force load...") end
        pcall(require, "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Greetings")
        pcall(require, "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Buying")
        pcall(require, "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Selling")
        pcall(require, "DT/Common/ArchetypeDefinitions/Player/Dialogue/DT_Player_Sell_ask")
    end

    -- 2. Resolve Pool via Core
    local category = "Buying"
    local subContext = "Generic"
    
    if action == "Sell" then 
        category = "Selling"
    elseif action == "Intro" or action == "Greetings" then 
        category = "Greetings"
        subContext = "Default"
    elseif action == "SellAsk" or action == "Sell_ask" then 
        category = "Sell_ask"
        subContext = "Default"
    elseif action == "NoCash" then 
        subContext = "NoCash"
    elseif action == "BuyLast" then 
        subContext = "LastStock"
    end
    
    -- Special case: NoCash can be for Buying or Selling. 
    -- Check Buying first, then Selling if needed.
    pool = Core.GetDialoguePool("Player", category, subContext)
    
    if (not pool or #pool == 0 or pool[1] == "...") and subContext == "NoCash" then
         pool = Core.GetDialoguePool("Player", "Selling", "NoCash")
    end

    if DynamicTrading.Debug then 
        DynamicTrading.Log("DTCommons", "Dialogue", "Player", "Resolving Player Pool for Category: " .. category .. " | Context: " .. subContext) 
        if not pool or pool[1] == "..." then
            DynamicTrading.Log("DTCommons", "Dialogue", "Warn", "Pool resolved to empty or fallback '...'")
        else
            DynamicTrading.Log("DTCommons", "Dialogue", "Player", "Pool resolved with " .. #pool .. " lines.")
        end
    end
    
    local rawText = Core.PickRandom(pool)
    if not rawText and DynamicTrading.Debug then
        DynamicTrading.Log("DTCommons", "Dialogue", "Debug", "Core.PickRandom returned NIL for action: " .. tostring(action))
    end
    rawText = rawText or "..."
    return Core.FormatMessage(rawText, args)
end

-- =============================================================================
-- 7. PLAYER SELL-ASK GENERATOR
-- =============================================================================
function DynamicTrading.Dialogue.Player.GeneratePlayerSellAskMessage()
    local pool = Core.GetDialoguePool("Player", "Sell_ask", "Default")
    local rawText = Core.PickRandom(pool)
    return Core.FormatMessage(rawText, {})
end
