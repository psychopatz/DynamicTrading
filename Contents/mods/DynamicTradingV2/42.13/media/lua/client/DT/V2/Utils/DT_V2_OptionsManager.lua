-- =============================================================================
-- DT_V2_OptionsManager (V2 Bridge)
-- =============================================================================

require "DT/Common/Utils/DT_AudioManager"
require "DT/Common/UI/DT_OptionsUI"

DT_V2_OptionsManager = {}

function DT_V2_OptionsManager.RegisterUI()
    if not DT_OptionsUI then return end

    -- V2 registers the same audio categories (shared)
    DT_OptionsUI.RegisterAudioCategory("Radio:", "Radio", "DT_RadioRandom")
    DT_OptionsUI.RegisterAudioCategory("Wallet:", "Wallet", "DT_CasinoRandom")
    DT_OptionsUI.RegisterAudioCategory("Trade:", "Trade", "DT_Cashier")
    DT_OptionsUI.RegisterAudioCategory("General:", "General", "DT_RadioBeep")

    -- V2 specific general settings (none yet, but Enable Sounds is shared)
    DT_OptionsUI.RegisterGeneralSetting("Enable Sounds", "enableSound", nil)

    print("[DT_V2_OptionsManager] V2 UI Registered.")
end

function DT_V2_OptionsManager.ToggleWindow()
    if DT_OptionsUI then
        DT_OptionsUI.ToggleWindow()
    end
end

-- Initialize Audio Categories for V2 too (Agnostic)
if DT_AudioManager then
    DT_AudioManager.RegisterCategory("DT_Radio", "Radio")
    DT_AudioManager.RegisterCategory("DT_Casino", "Wallet")
    DT_AudioManager.RegisterCategory("DT_Cashier", "Trade")
end

-- Register UI
DT_V2_OptionsManager.RegisterUI()
