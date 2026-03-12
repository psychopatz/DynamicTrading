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
    for k, v in pairs(DynamicTrading.Config.MasterList) do
        if v.item == fullType then return k end
    end
    return nil
end
