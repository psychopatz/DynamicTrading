-- =============================================================================
-- DT_DialogueManager.lua (COMMON FACADE)
-- =============================================================================
-- This file serves as the main entry point for Dialogue components.
-- It unifies the logic for both V1 and V2 by delegating to specific modules.
-- =============================================================================

require "DT/Common/Dialogue/DT_Dialogue_Core"
require "DT/Common/Dialogue/DT_Dialogue_Trader"
require "DT/Common/Dialogue/DT_Dialogue_Player"

DynamicTrading = DynamicTrading or {}
DynamicTrading.DialogueManager = {}

local Core = DynamicTrading.Dialogue.Core
local TraderLog = DynamicTrading.Dialogue.Trader
local PlayerLog = DynamicTrading.Dialogue.Player

-- =============================================================================
-- PUBLIC API (Delegates)
-- =============================================================================

-- Greeting
function DynamicTrading.DialogueManager.GenerateGreeting(trader)
    return TraderLog.GenerateGreeting(trader)
end

-- Idle
function DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
    return TraderLog.GenerateIdleMessage(trader)
end

-- Ambient (Weather/Time)
function DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, eventType)
    return TraderLog.GenerateAmbientMessage(trader, eventType)
end

-- Transaction (Buy/Sell/Fail)
function DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, args)
    return TraderLog.GenerateTransactionMessage(trader, isBuy, args)
end

-- Trader "What are you selling?"
function DynamicTrading.DialogueManager.GenerateSellAskDialogue(trader)
    return TraderLog.GenerateSellAskDialogue(trader)
end

-- Player "I want to buy..."
function DynamicTrading.DialogueManager.GeneratePlayerMessage(action, args)
    return PlayerLog.GeneratePlayerMessage(action, args)
end

-- Player "What are you buying?"
function DynamicTrading.DialogueManager.GeneratePlayerSellAskMessage()
    return PlayerLog.GeneratePlayerSellAskMessage()
end

-- Generic direct fetch (Low level)
function DynamicTrading.DialogueManager.GetDialogue(trader, category, subContext, args)
    if not trader or not category or not subContext then return "..." end
    
    local safeArgs = args or {}
    if trader.name and not safeArgs.traderName then
        safeArgs.traderName = trader.name
    end
    
    local pool = Core.GetDialoguePool(trader.archetype, category, subContext)
    local rawText = Core.PickRandom(pool)
    return Core.FormatMessage(rawText, safeArgs)
end

DynamicTrading.Log("DTCommons", "Init", "Dialogue", "Dialogue Manager (Common) Loaded")
