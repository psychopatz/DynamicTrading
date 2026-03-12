-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WRAPPER - DIALOGUE
-- =============================================================================
-- Delegates dialogue generation to the Common DialogueManager.
-- =============================================================================

V1_RadioTradingWrapper_Dialogue_logic = {}

function V1_Radio_DataProvider:getAmbientMessage(trader, event)
    if not DynamicTrading.DialogueManager then return nil end
    return DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, event)
end

function V1_Radio_DataProvider:getGreeting(trader)
    if not DynamicTrading.DialogueManager then return "Hello." end
    return DynamicTrading.DialogueManager.GenerateGreeting(trader)
end

function V1_Radio_DataProvider:getPlayerMessage(category, diagArgs)
    if not DynamicTrading.DialogueManager then return "..." end
    return DynamicTrading.DialogueManager.GeneratePlayerMessage(category, diagArgs)
end

function V1_Radio_DataProvider:getTransactionMessage(trader, isBuy, diagArgs)
    if not DynamicTrading.DialogueManager then return isBuy and "Done." or "No deal." end
    return DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, diagArgs)
end

function V1_Radio_DataProvider:getSellAskDialogue(trader)
    if DynamicTrading.DialogueManager and DynamicTrading.DialogueManager.GenerateSellAskDialogue then
        return DynamicTrading.DialogueManager.GenerateSellAskDialogue(trader)
    end
    return "What do you have for me?"
end

function V1_Radio_DataProvider:getIdleMessage(trader)
    if not DynamicTrading.DialogueManager then return nil end
    return DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
end

DynamicTrading.Log("DTV1", "Init", "Dialogue", "V1 Radio Trading Dialogue Logic Loaded")
