-- =============================================================================
-- DT_OptionsManager (V1 Bridge & Wrapper)
-- Unifies Audio Category Registration and UI Configuration for V1
-- =============================================================================

require "DT/Common/Utils/DT_AudioManager"
require "DT/Common/UI/DT_OptionsUI"
require "DT/V1/UI/DT_SidebarButton"

DT_OptionsManager = {}

-- =============================================================================
-- 1. AUDIO REGISTRATION
-- =============================================================================
function DT_OptionsManager.RegisterAudio()
    if not DT_AudioManager then
        print("[DT_OptionsManager] ERROR: Common DT_AudioManager not found!")
        return
    end

    -- Register V1 specific map
    DT_AudioManager.RegisterCategory("DT_Radio", "Radio")
    DT_AudioManager.RegisterCategory("DT_Casino", "Wallet")
    DT_AudioManager.RegisterCategory("DT_Cashier", "Trade")

    print("[DT_OptionsManager] V1 Audio Categories Registered.")
end

-- =============================================================================
-- 2. UI REGISTRATION
-- =============================================================================
function DT_OptionsManager.RegisterUI()
    if not DT_OptionsUI then return end

    -- Audio Categories
    DT_OptionsUI.RegisterAudioCategory("Radio:", "Radio", "DT_RadioRandom")
    DT_OptionsUI.RegisterAudioCategory("Wallet:", "Wallet", "DT_CasinoRandom")
    DT_OptionsUI.RegisterAudioCategory("Trade:", "Trade", "DT_Cashier")
    DT_OptionsUI.RegisterAudioCategory("General:", "General", "DT_RadioBeep")

    -- General Settings
    DT_OptionsUI.RegisterGeneralSetting("Show Sidebar Button", "showSidebar", function(val) 
        if DT_SidebarButton and DT_SidebarButton.UpdateVisibility then 
            DT_SidebarButton.UpdateVisibility() 
        end 
    end)
    
    DT_OptionsUI.RegisterGeneralSetting("Enable Sounds", "enableSound", nil)

    print("[DT_OptionsManager] V1 UI Registered.")
end

-- =============================================================================
-- 3. UNIFIED ENTRY POINTS
-- =============================================================================
function DT_OptionsManager.ToggleWindow()
    if DT_OptionsUI then
        DT_OptionsUI.ToggleWindow()
    end
end

-- =============================================================================
-- INITIALIZATION
-- =============================================================================
DT_OptionsManager.RegisterAudio()
DT_OptionsManager.RegisterUI()
