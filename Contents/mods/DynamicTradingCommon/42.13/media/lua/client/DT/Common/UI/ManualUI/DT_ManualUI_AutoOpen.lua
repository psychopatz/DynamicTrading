require "Utils/DT_ConfigManager"
require "DT/Common/UI/ManualUI/DT_ManualUI_Definition"

DT_ManualUI_AutoOpen = DT_ManualUI_AutoOpen or {
    checked = false,
}

local function tryOpenWhatsNew()
    if DT_ManualUI_AutoOpen.checked then
        return
    end

    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player then
        return
    end

    if not DynamicTrading or not DynamicTrading.Manuals or not DynamicTrading.Manuals.GetLatestWhatsNewManual then
        return
    end

    local manual = DynamicTrading.Manuals.GetLatestWhatsNewManual()
    local version = manual and tostring(manual.popupVersion or manual.releaseVersion or "") or ""
    if not manual or version == "" then
        return
    end

    local blockedVersion = DT_ConfigManager and DT_ConfigManager.getDisabledAutoOpenReleaseVersion and DT_ConfigManager.getDisabledAutoOpenReleaseVersion() or ""
    if blockedVersion == version then
        DT_ManualUI_AutoOpen.checked = true
        return
    end

    local lastSeen = DT_ConfigManager and DT_ConfigManager.getLastSeenReleaseVersion and DT_ConfigManager.getLastSeenReleaseVersion() or ""
    if lastSeen == version then
        DT_ManualUI_AutoOpen.checked = true
        return
    end

    local lastAutoOpened = DT_ConfigManager and DT_ConfigManager.getLastAutoOpenedReleaseVersion and DT_ConfigManager.getLastAutoOpenedReleaseVersion() or ""
    if lastAutoOpened == version then
        if DT_ConfigManager and DT_ConfigManager.setLastAutoOpenedReleaseVersion then
            DT_ConfigManager.setLastAutoOpenedReleaseVersion("")
        end
    end

    if DT_ConfigManager and DT_ConfigManager.setLastAutoOpenedReleaseVersion then
        DT_ConfigManager.setLastAutoOpenedReleaseVersion(version)
    end

    DT_ManualUI_AutoOpen.checked = true

    DynamicTrading.Manuals.OpenUpdates({
        manualId = manual.id,
        pageId = manual.startPageId,
    })
end

Events.OnGameStart.Add(function()
    DT_ManualUI_AutoOpen.checked = false
    tryOpenWhatsNew()
end)
Events.OnCreatePlayer.Add(function(playerIndex)
    if playerIndex == 0 then
        tryOpenWhatsNew()
    end
end)
