local internal = DT_ConfigManagerInternal

function DT_ConfigManager.toggleSound()
    DT_ConfigManager.settings.enableSound = not DT_ConfigManager.settings.enableSound
    DT_ConfigManager.save()
    return DT_ConfigManager.settings.enableSound
end

function DT_ConfigManager.setShowSidebar(isVisible)
    DT_ConfigManager.settings.showSidebar = isVisible
    DT_ConfigManager.save()
end

function DT_ConfigManager.setDebugLogs(enabled)
    DT_ConfigManager.settings.debugLogs = enabled == true
    DynamicTrading.Debug = DT_ConfigManager.settings.debugLogs
    DT_ConfigManager.save()
end

function DT_ConfigManager.setVolume(category, level)
    local clampedLevel = internal.clampUnit(level, 1.0)

    if category == "Master" then
        DT_ConfigManager.settings.volMaster = clampedLevel
    elseif category == "Radio" then
        DT_ConfigManager.settings.volRadio = clampedLevel
    elseif category == "Wallet" then
        DT_ConfigManager.settings.volWallet = clampedLevel
    elseif category == "Trade" then
        DT_ConfigManager.settings.volTrade = clampedLevel
    elseif category == "General" then
        DT_ConfigManager.settings.volGeneral = clampedLevel
    end

    DT_ConfigManager.save()
end

function DT_ConfigManager.setConversationOverlayOpacity(level)
    DT_ConfigManager.settings.conversationOverlayOpacity = internal.clampUnit(
        level,
        DT_ConfigManager.defaultSettings.conversationOverlayOpacity
    )
    DT_ConfigManager.save()
end

function DT_ConfigManager.getConversationOverlayOpacity()
    return internal.clampUnit(
        DT_ConfigManager.settings.conversationOverlayOpacity,
        DT_ConfigManager.defaultSettings.conversationOverlayOpacity
    )
end

function DT_ConfigManager.setConversationTransparencyDisabled(disabled)
    DT_ConfigManager.settings.disableConversationTransparency = disabled == true
    DT_ConfigManager.save()
end

function DT_ConfigManager.isConversationTransparencyDisabled()
    if DT_ConfigManager.settings.disableConversationTransparency == nil then
        return DT_ConfigManager.defaultSettings.disableConversationTransparency == true
    end
    return DT_ConfigManager.settings.disableConversationTransparency == true
end

function DT_ConfigManager.shouldPlaySound()
    return DT_ConfigManager.settings.enableSound
end

function DT_ConfigManager.getVolume(category)
    if category == "Master" then
        return DT_ConfigManager.settings.volMaster or 1.0
    elseif category == "Radio" then
        return DT_ConfigManager.settings.volRadio or 1.0
    elseif category == "Wallet" then
        return DT_ConfigManager.settings.volWallet or 0.5
    elseif category == "Trade" then
        return DT_ConfigManager.settings.volTrade or 0.5
    elseif category == "General" then
        return DT_ConfigManager.settings.volGeneral or 0.5
    end
    return 1.0
end
