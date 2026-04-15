-- =============================================================================
-- TradingWindowWrapper_Core.lua
-- Core provider helpers shared by wrapper modules.
-- =============================================================================

V2_DataProvider = V2_DataProvider or {}

function V2_DataProvider:countTable(t)
    local count = 0
    if t then for _ in pairs(t) do count = count + 1 end end
    return count
end

function V2_DataProvider:getMasterKey(fullType)
    return DynamicTrading.Utils.GetMasterKey(fullType)
end
