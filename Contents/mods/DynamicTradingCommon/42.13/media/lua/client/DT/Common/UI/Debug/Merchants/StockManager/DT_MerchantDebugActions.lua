-- ==============================================================================
-- DT_MerchantDebugActions.lua
-- Merchant Debug Tool: Action Handlers
-- Button click handlers for stock generation
-- ==============================================================================

require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"

DT_MerchantDebugActions = DT_MerchantDebugActions or {}

-- ==========================================================
-- STOCK GENERATION
-- ==========================================================
function DT_MerchantDebugActions.generateStock(traderID, traderName)
    if not traderID then 
        print("[DT-Debug] Cannot generate stock: no trader ID")
        return false 
    end
    
    print("DT DEBUG: Requesting Stock for " .. tostring(traderID))
    DT_DebugNetworkAdapter.generateStock(traderID)
    return true
end

-- ==========================================================
-- STOCK REFRESH EVENT
-- ==========================================================
function DT_MerchantDebugActions.onStockUpdated(traderID, callback)
    if callback then
        callback(traderID)
    end
end

print("[DT-Debug] Merchant Debug Actions Loaded")
