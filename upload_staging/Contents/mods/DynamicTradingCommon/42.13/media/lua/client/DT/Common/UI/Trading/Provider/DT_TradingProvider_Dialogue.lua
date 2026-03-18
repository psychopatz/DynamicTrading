-- =============================================================================
-- DYNAMIC TRADING: COMMON TRADING PROVIDER - DIALOGUE
-- =============================================================================
-- Shared dialogue helpers for trading data providers (V1/V2).
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.TradingProvider = DynamicTrading.TradingProvider or {}

function DynamicTrading.TradingProvider.AttachDialogue(provider)
    if not provider then return end

    if provider.getAmbientMessage == nil then
        function provider:getAmbientMessage(trader, event)
            if not DynamicTrading.DialogueManager then return nil end
            return DynamicTrading.DialogueManager.GenerateAmbientMessage(trader, event)
        end
    end

    if provider.getGreeting == nil then
        function provider:getGreeting(trader)
            if not DynamicTrading.DialogueManager then return "Hello." end
            return DynamicTrading.DialogueManager.GenerateGreeting(trader)
        end
    end

    if provider.getPlayerMessage == nil then
        function provider:getPlayerMessage(category, diagArgs)
            if not DynamicTrading.DialogueManager then return "..." end
            return DynamicTrading.DialogueManager.GeneratePlayerMessage(category, diagArgs)
        end
    end

    if provider.getTransactionMessage == nil then
        function provider:getTransactionMessage(trader, isBuy, diagArgs)
            if not DynamicTrading.DialogueManager then return isBuy and "Done." or "No deal." end
            return DynamicTrading.DialogueManager.GenerateTransactionMessage(trader, isBuy, diagArgs)
        end
    end

    if provider.getSellAskDialogue == nil then
        function provider:getSellAskDialogue(trader)
            if DynamicTrading.DialogueManager and DynamicTrading.DialogueManager.GenerateSellAskDialogue then
                return DynamicTrading.DialogueManager.GenerateSellAskDialogue(trader)
            end
            return "What do you have for me?"
        end
    end

    if provider.getIdleMessage == nil then
        function provider:getIdleMessage(trader)
            if not DynamicTrading.DialogueManager then return nil end
            return DynamicTrading.DialogueManager.GenerateIdleMessage(trader)
        end
    end
end
