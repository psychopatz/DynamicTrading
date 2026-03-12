-- =============================================================================
-- TradingWindowWrapper_UI.lua
-- UI-facing configuration methods for the trading provider.
-- =============================================================================

V2_DataProvider = V2_DataProvider or {}

function V2_DataProvider:playSound(soundName)
    if DT_AudioManager then
        DT_AudioManager.PlaySound(soundName, false, 1.0)
    else
        getSoundManager():PlaySound(soundName, false, 1.0)
    end
end

function V2_DataProvider:getLockButtonVisible(isBuying)
    return not isBuying
end

function V2_DataProvider:getArchetypeName(archetype)
    if DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetype] then
        return DynamicTrading.Archetypes[archetype].name
    end
    return archetype or "Survivor"
end

function V2_DataProvider:getWindowTitle(trader)
    if not trader then return "Trading" end
    local name = trader.name or "Unknown"
    local archName = self:getArchetypeName(trader.archetype)
    return name .. " - " .. archName
end
