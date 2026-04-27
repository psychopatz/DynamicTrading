-- =============================================================================
-- DT_V2_OptionsManager (V2 Bridge)
-- =============================================================================

require "DT/Common/Utils/DT_AudioManager"
require "DT/Common/UI/DT_OptionsUI"

DT_V2_OptionsManager = {}

local function isCurrencyExpandedActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("CurrencyExpanded") or false
end

local function refreshPortraitUIs()
    if DT_TradingWindow and DT_TradingWindow.instance and DT_TradingWindow.instance.refreshPortraitWithTrader then
        local trader = DT_TradingWindow.instance:getCurrentTrader()
        if trader then
            DT_TradingWindow.instance:refreshPortraitWithTrader(trader, true)
        end
    end

    if DT_ConversationUI and DT_ConversationUI.instance and DT_ConversationUI.instance.refreshPortrait then
        DT_ConversationUI.instance:refreshPortrait(true)
    end

    if DT_RadioScannerWindow and DT_RadioScannerWindow.instance and DT_RadioScannerWindow.instance.refreshTrackingPresentation then
        DT_RadioScannerWindow.instance:refreshTrackingPresentation(true)
    end
end

function DT_V2_OptionsManager.RegisterUI()
    if not DT_OptionsUI then return end

    -- V2 registers the same audio categories (shared)
    DT_OptionsUI.RegisterAudioCategory("Radio:", "Radio", "DT_RadioRandom")
    DT_OptionsUI.RegisterAudioCategory("Trade:", "Trade", "DT_Cashier")
    DT_OptionsUI.RegisterAudioCategory("General:", "General", "DT_RadioBeep")

    if isCurrencyExpandedActive() then
        DT_OptionsUI.RegisterAudioCategory("Wallet:", "Wallet", "CE_CasinoRandom")
    end

    -- V2 specific general settings (none yet, but Enable Sounds is shared)
    DT_OptionsUI.RegisterGeneralSetting("Enable Sounds", "enableSound", nil)
    DT_OptionsUI.RegisterGeneralSetting("Enable Debug Logs", "debugLogs", function(selected)
        if DT_ConfigManager and DT_ConfigManager.setDebugLogs then
            DT_ConfigManager.setDebugLogs(selected)
        else
            DynamicTrading.Debug = selected == true
        end
    end)
    DT_OptionsUI.RegisterGeneralSetting("Use 3D Portraits", "use3DPortraits", function()
        refreshPortraitUIs()
    end)
    DT_OptionsUI.RegisterGeneralSetting("Disable Transparency", "disableConversationTransparency", nil)

    DynamicTrading.Log("DTV2", "Init", "Config", "V2 UI Registered.")
end

function DT_V2_OptionsManager.ToggleWindow()
    if DT_OptionsUI then
        DT_OptionsUI.ToggleWindow()
    end
end

-- Initialize Audio Categories for V2 too (Agnostic)
if DT_AudioManager then
    DT_AudioManager.RegisterCategory("DT_Radio", "Radio")
    DT_AudioManager.RegisterCategory("DT_Cashier", "Trade")

    if isCurrencyExpandedActive() then
        DT_AudioManager.RegisterCategory("CE_Casino", "Wallet")
        DT_AudioManager.RegisterCategory("CE_Cashier", "Wallet")
    end
end

-- Register UI
DT_V2_OptionsManager.RegisterUI()
