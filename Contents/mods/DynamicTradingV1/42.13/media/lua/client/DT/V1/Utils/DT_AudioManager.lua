-- =============================================================================
-- DT_AudioManager (V1 Bridge)
-- Uses Common Audio Manager and registers V1-specific categories
-- =============================================================================

require "DT/Common/Utils/DT_AudioManager"

-- Check if Common loaded correctly
if not DT_AudioManager then
    print("[DT_AudioManager] ERROR: Common DT_AudioManager not found!")
    return
end

-- =============================================================================
-- V1 Sound Category Registration
-- =============================================================================

-- Register V1 specific map
DT_AudioManager.RegisterCategory("DT_Radio", "Radio")
DT_AudioManager.RegisterCategory("DT_Casino", "Wallet")
DT_AudioManager.RegisterCategory("DT_Cashier", "Trade")

print("[DT_AudioManager] V1 Audio Categories Registered in Common Manager.")
